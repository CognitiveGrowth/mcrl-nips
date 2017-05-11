meta_MDP=metaMDP()

PRs = new Array()
action_was_click = new Array()
action_was_move = new Array()

moves   = new Array()
clicks  = new Array()

function metaMDP(){

    trials=getTrials()    
    clicks=[]
    
    var meta_MDP={
        cost_per_click: 0.10,
        cost_per_planning_step: 0.01,
        mean_payoff: 4.5,
        std_payoff: 10.6,        
        object_level_MDPs: trials,
        object_level_MDP: [],
        locations: [],
        state: [],
        locations_by_step: [],
        locations_by_path: [],
        action_nrs: {right: 1, up: 2, left: 3, down: 4},
        delay_per_point: [],        
        init: function(problem_nr){
            this.object_level_MDP=this.object_level_MDPs[problem_nr]
            this.locations=getLocations(problem_nr)            
            
            subject_value_of_1h=10; //50 dollars worth of subjective utility per hour
            nr_trials = Object.size(this.object_level_MDPs)
            sec_per_h=3600
            this.delay_per_point = 0.05/(subject_value_of_1h*nr_trials)*sec_per_h;
            
            var state={
                mu_Q: new Array(Object.size(this.locations)),
                sigma_Q: new Array(Object.size(this.locations)),
                mu_V: new Array(Object.size(this.locations)),
                sigma_V: new Array(Object.size(this.locations)),
                s: 1,
                nr_steps: 3,
                step: 1,
                observations: getObservations(clicks,this.locations),
                moves: new Array(Object.size(this.locations))
            }
            
            this.locations_by_step= new Array(4)
            this.locations_by_path= new Array()
            for (s=0; s<this.locations_by_step.length; s++){
                this.locations_by_step[s]=new Array()
            }
            for (l in this.locations){
                locus=this.locations[l]
                this.locations_by_step[locus.path.length].push(locus)                
                this.locations_by_path[locus.path.toString()]=locus
            }
            
            this.state=updateBelief(this,state,_.range(1,state.observations.length+1))
        },
        rational_moves: function(belief_state){
            
            var current_location = meta_MDP.locations[meta_MDP.state.s]            
            var action_index=argmax(belief_state.mu_Q[belief_state.s-1])
            
            var rational_moves = new Array()
            for (var i=0; i<action_index.length; i++){
                rational_moves.push(belief_state.moves[belief_state.s-1][action_index[i]])
            }
            return rational_moves
        }
    }

    return meta_MDP;
}

function getPR(state,actions){
  
    var next_state=getNextState(state,actions,true)
    var environment_model=getNextState(state,actions.slice(0,-1),true) //information state after having thought but before having taken action
    
    var V_new=valueFunction(next_state,environment_model)
    var V_old=valueFunction(state,environment_model)
    
    var reward=0
    
    for (a in actions){
        if (actions[a].is_move){
            if (isNaN(environment_model.observations[actions[a].move.next_state-1]) || environment_model.observations[actions[a].move.next_state-1]==null){
                var ER=meta_MDP.mean_payoff
            }
            else{
                var ER=environment_model.observations[actions[a].move.next_state-1];
            }
            
            reward+=ER-costOfPlanning(state,actions[a].planning_horizon)
        }
        else{
            reward-=meta_MDP.cost_per_click
        }
    }
    
    var PR=V_new-V_old+reward

    return PR
    //To improve the quality of the feedback, we could use E[V(S_{t+1})] instead of V(s_{t+1}).
    //This would take longer to compute and would also be more effort to implement.
}

function computeDelay(initial_state,actions){   
    //returns the delay in seconds corresponding to the PR for starting in initial_state and taking the actions in the array actions
        
    total_PR=getPR(initial_state,actions)
    
    delay=-meta_MDP.delay_per_point*total_PR
    
    return delay
    
}

function registerMove(direction){
    
    var last_move=action_was_move.lastIndexOf(true)
    
    action_was_click.push(false)
    action_was_move.push(true)

    var current_location = meta_MDP.locations[meta_MDP.state.s]
    var available_moves=getMoves(current_location)
    
    var action_nr=meta_MDP.action_nrs[direction]
    
    
    for (a in available_moves){
        
        if (available_moves[a].move.action_nr==action_nr){
            var move = {
                is_move: true,
                is_click: false,
                cell: [],
                move: {
                    next_state: available_moves[a].move.next_state,
                    reward: available_moves[a].move.reward,
                    direction: direction,
                    action_nr: action_nr
                },
                planning_horizon: meta_MDP.state.nr_steps-meta_MDP.state.step+1
            }

            moves.push(move)
        }
    }
    
    if (condition==1){        
        var delay=computeDelay(meta_MDP.state,clicks.concat([move]))                
    }
    else{
        var delay=0
    }

    
    var last_move = moves.slice(-1).pop()
    
    var updated_belief=deepCopy(meta_MDP.state)
    updated_belief.observations=getObservations(clicks,meta_MDP.locations)
    updated_belief=updateBelief(meta_MDP,updated_belief,_.range(1,updated_belief.observations.length+1))
    var information_used_correctly= _.contains(meta_MDP.rational_moves(updated_belief), last_move.move.direction)

    //check if all of the successor states have been inspected
    var downstream=getDownStreamStates(meta_MDP.state)
        
    var planned_too_little=false
    
    var available_moves = getMoves(meta_MDP.locations[updated_belief.s])
    if (Object.size(available_moves)>1){ //it is impossible to plan too much if there is no choice    
        for (var u in downstream){
            if (isNaN(updated_belief.observations[downstream[u]]) || updated_belief.observations[downstream[u]] == null){
                planned_too_little=true
            }
        }
        var inevitable=[]
    }
    else{
        var inevitable= [available_moves[0].move.next_state];
    }
    
    
    if (available_moves.length==1){
        
    }
    var relevant=setDiff(downstream,inevitable)
    var planned_too_much=false
    for (c in clicks){
        
        if (!_.contains(relevant, clicks[c].cell-1)){
            planned_too_much=true
        }
    }
    
    meta_MDP.state=getNextState(meta_MDP.state,clicks.concat([move]),true)    
    
    clicks=[]

    
    return {delay: delay,
            planned_too_little: planned_too_little,
            planned_too_much: planned_too_much,
            information_used_correctly: information_used_correctly
           }
}

function registerClick(cell_nr){
    action_was_click.push(true)
    action_was_move.push(false)
    
    click = {
        is_move: false,
        is_click: true,
        cell: cell_nr,
        move: []
    }        
    
    clicks.push(click)
}

function getNextState(state,actions,update_belief){
    
    if (update_belief === undefined){
        var update_belief=true;
    }
    
    var next_state=deepCopy(state)
    
    if (!(actions.constructor === Array) ){
        temp=clone(actions)
        actions = new Array()
        actions.push(temp)
    }
    
    at_least_one_click=false
    var observed_outcomes = new Array()
    
    for (a in actions){

        action= actions[a]
        
        if (action.is_click){        
            next_state.observations[action.cell-1]=meta_MDP.locations[action.cell].reward
            
            if (!isNumber(next_state.observations[action.cell-1])){
                alert('something went wrong: action.cell='+action.cell)
            }
            
            at_least_one_click=true
            observed_outcomes.push(action.cell)
        }
    
        if (action.is_move){            
            next_state.s=action.move.next_state
            next_state.observations[next_state.s-1]=meta_MDP.locations[next_state.s].reward
            observed_outcomes.push(next_state.s)
            next_state.step++
        }
    }
     
    if (update_belief){
        next_state=updateBelief(meta_MDP,next_state,observed_outcomes)
    }


    
    return next_state
}

function getActions(state){
    
    var actions=new Array()
    
    var current_location=meta_MDP.locations[state.s]
    
    actions=getMoves(current_location).concat(getClicks())
        
    return actions
}

function getMoves(current_location){
    //moves
    var moves=new Array()
    
    var available_actions=current_location.actions
    for (move in available_actions){
        
        move={
            is_move: true,
            is_click: false,
            cell: [],
            move: {
                next_state: available_actions[move][0],
                reward: available_actions[move][1],
                direction: move,
                action_nr: meta_MDP.action_nrs[move]
            }
        }
        
        moves.push(move)
    }
    
    return moves
}

function getClicks(state){
    
    //clicks
    var clicks = new Array()
    
    for (o in state.observations){
        
        if (isNaN(state.observations[o]) || state.observations[o]==null){
            
            click={
                is_move: false,
                is_click: true,
                cell: parseInt(o),
                move: []
            }
            
            clicks.push(click)
        }
    }
    
    return clicks
}

function getLocations(problem_nr){
    
    var locations = meta_MDP.object_level_MDPs[problem_nr].graph
    
    for (l in locations){
        
        locations[l].nr=parseInt(l);
        
        if (isEmpty(locations[l].path)){
            locations[l].path=[]
        }
        else{        
            if (isScalar(locations[l].path)){
                locations[l].path=[locations[l].path]
            }
        
            if (!isScalar(locations[l].path[0])){
                locations[l].path=[].concat.apply([],locations[l].path)
            }
        }
    }
    return locations
}

function getTrials(){
    var experiment = loadJson("static/json/condition_0.json");
    var trials=experiment.trials;
    return trials
}


function getObservations(clicks,locations){
    var observations=new Array(Object.size(locations))
    
    for (var o=0; o<observations.length; o++){
        observations[o]=NaN;
    }
    
    
    for (c in clicks){
            observations[clicks[c].cell-1] = locations[clicks[c].cell].reward           
    }
    
    return observations
}

function updateBelief(meta_MDP,state,new_observations){
    /* 
        computes state.mu_Q, state.sigma_Q, state.mu_V, and
        state.sigma_V from meta_MDP.observations and meta_MDP
        mu_Q(s,a): expected return of starting in object-level state s and performing object-level action a according to meta_MDP.observations and meta_MDP.p_payoffs 
        mu_V(s): expected return of starting in object-level state s and following the optimal object-level policy according to meta_MDP.observations and meta_MDP.p_payoffs. The expectation is taken with respect to the probability distribution encoded by the meta-level state and the ?optimal policy? maximizes the reward expected according to the probability distribution encoded by the meta-level state
        sigma_Q(s,a), sigma_V(s): uncertainty around the expectations mu_Q(s,a) and mu_V(s).
    */
    
    //0. Determine which beliefs have to be updated
    var needs_updating=getUpStreamStates(new_observations);


    //1. Set value of starting from the leave states to zero
    var leaf_nodes=meta_MDP.locations_by_step[state.nr_steps];
    for (var l=0; l<leaf_nodes.length; l++){
        state.mu_V[leaf_nodes[l].nr-1]=0;
        state.sigma_V[leaf_nodes[l].nr-1]=0;
    }
        
    
    //2. Propagage the update backwards towards the initial state
    nr_steps=meta_MDP.locations_by_step.length
    
    for (var step=nr_steps-2; step>=0; step--){

        var nodes=meta_MDP.locations_by_step[step]
        // a) Update belief about state-action values
        for (var n=0; n<nodes.length; n++){
            var node=nodes[n];

            if (_.contains(needs_updating,node.nr)){
                state.mu_Q[node.nr-1]=new Array()
                state.sigma_Q[node.nr-1]=new Array()
                state.moves[node.nr-1] = new Array()
                
                for (var a in node.actions){
                    var action=node.actions[a];
                    
                    var action_nr=meta_MDP.action_nrs[a];
                    
                    var next_state=meta_MDP.locations_by_path[node.path.concat(action_nr).toString()];

                    if (isNaN(state.observations[next_state.nr-1]) || state.observations[next_state.nr-1]==null){
                        state.mu_Q[node.nr-1].push(meta_MDP.mean_payoff+state.mu_V[next_state.nr-1]);
                        state.sigma_Q[node.nr-1].push(Math.sqrt(Math.pow(meta_MDP.std_payoff,2)+Math.pow(state.sigma_V[next_state.nr-1],2)));
                    }
                    else{
                        state.mu_Q[node.nr-1].push(state.observations[next_state.nr-1]+state.mu_V[next_state.nr-1])
                        state.sigma_Q[node.nr-1].push(state.sigma_V[next_state.nr-1])                        
                    }
                    state.moves[node.nr-1].push(a)
                }

                //b) Update belief about state value V
                var EV_and_sigma=EVOfMaxOfGaussians(state.mu_Q[node.nr-1],state.sigma_Q[node.nr-1]);
                state.mu_V[node.nr-1]=EV_and_sigma[0];
                state.sigma_V[node.nr-1]=EV_and_sigma[1];

            }
        }

    }           
    
    return state       
}

function valueFunction(state,environment_model){        
        
    var current_location=state.s;
    var planning_horizon=state.nr_steps-state.step+1;
    var planning_cost=0;
    var step=state.step-1;
    
    for (var ph=planning_horizon; ph>0; ph--){
        var start_location=meta_MDP.locations_by_step[step++][0]
        var start_state = {
            s: start_location.nr,
            step: step,
            nr_steps: state.nr_steps,
            observations: new Array(Object.size(meta_MDP.locations)),
            mu_Q: new Array(Object.size(meta_MDP.locations)),
            sigma_Q: new Array(Object.size(meta_MDP.locations)),
            mu_V: new Array(Object.size(meta_MDP.locations)),
            sigma_V: new Array(Object.size(meta_MDP.locations)),
            moves: new Array(Object.size(meta_MDP.locations))
        }
        planning_cost+=costOfPlanning(start_state,ph);
    }

    var downstream=getDownStreamStates(state);
    
    var to_be_observed=0
    for (var i in state.observations){
        if (_.contains(downstream,parseInt(i))){
            if (isNaN(state.observations[parseInt(i)]) || state.observations[parseInt(i)] == null ){
                to_be_observed++
            }
        }
    }
        
    var information_cost=meta_MDP.cost_per_click*to_be_observed

    var V=environment_model.mu_V[current_location-1]-planning_cost-information_cost;
    
    return V
}

function costOfPlanning(state,planning_horizon){
    //compute the number and length of all paths from the current 
    var current_location=meta_MDP.locations[state.s];
    var moves=getMoves(current_location);

    var cost_of_planning=0;
    if (planning_horizon>0){
        for (m in moves){
            var move=moves[m];
            var next_state=getNextState(state,move,false);
            var next_planning_horizon=planning_horizon-1;
            
            cost_of_planning+=meta_MDP.cost_per_planning_step+costOfPlanning(next_state,next_planning_horizon);
        }
    }
    
    return cost_of_planning
}

function getDownStreamStates(state){
    var downstream=[];

    var states=meta_MDP.locations;
    var current_path=states[state.s].path;
    var path_length=current_path.length

    if (current_path.length==0){
        downstream=_.range(1,Object.size(states));
    }
    else{                    
        for (s=1; s<=Object.size(states); s++){
            if (states[s].path.slice(0,path_length).equals(current_path) && states[s].path.length>path_length){
                downstream.push(s);
            }

        }
    }

    return downstream                
}

function getUpStreamStates(observed_states){
    var upstream=[];

    var states=meta_MDP.locations
    
    for (o=0; o<observed_states.length; o++){
        var current_path=states[observed_states[o]].path;    

        if (current_path.length>0){                    
            for (s=1; s<=Object.size(states); s++){

                var path_length=states[s].path.length

                if (path_length < current_path.length){
                    if (states[s].path.equals(current_path.slice(0,path_length))){
                        upstream.push(s);
                    }
                }
            }

        }
    }

    return upstream
                
}


checkObj = function(obj, keys) {
  var i, k, len;
  if (keys == null) {
    keys = Object.keys(obj);
  }
  for (i = 0, len = keys.length; i < len; i++) {
    k = keys[i];
    if (obj[k] === void 0) {
      console.log('Bad Object: ', obj);
      throw new Error(k + " is undefined");
    }
  }
  return obj;
};

assert = function(val) {
  if (!val) {
    throw new Error('Assertion Error');
  }
  return val;
};

checkWindowSize = function(width, height, display) {
  var maxHeight, win_width;
  win_width = $(window).width();
  maxHeight = $(window).height();
  if ($(window).width() < width || $(window).height() < height) {
    display.hide();
    return $('#window_error').show();
  } else {
    $('#window_error').hide();
    return display.show();
  }
};

// Warn if overriding existing method
if(Array.prototype.equals)
    console.warn("Overriding existing Array.prototype.equals. Possible causes: New API defines the method, there's a framework conflict or you've got double inclusions in your code.");
// attach the .equals method to Array's prototype to call it on any array
Array.prototype.equals = function (array) {
    // if the other array is a falsy value, return
    if (!array)
        return false;

    // compare lengths - can save a lot of time 
    if (this.length != array.length)
        return false;

    for (var i = 0, l=this.length; i < l; i++) {
        // Check if we have nested arrays
        if (this[i] instanceof Array && array[i] instanceof Array) {
            // recurse into the nested arrays
            if (!this[i].equals(array[i]))
                return false;       
        }           
        else if (this[i] != array[i]) { 
            // Warning - two different object instances will never be equal: {x:20} != {x:20}
            return false;   
        }           
    }       
    return true;
}
// Hide method from for-in loops
Object.defineProperty(Array.prototype, "equals", {enumerable: false});

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};


	
function isScalar(obj){
    return (/string|number|boolean/).test(typeof obj);
}

function isEmpty(val){
    return (val === undefined || val == null || val.length <= 0) ? true : false;
}

function deepCopy(some_array){
    return JSON.parse(JSON.stringify(some_array))
}

function clone(obj) {
    if (null == obj || "object" != typeof obj) return obj;
    var copy = obj.constructor();
    for (var attr in obj) {
        if (obj.hasOwnProperty(attr)){
            
            if (typeof(obj[attr]) === "object"){
                copy[attr]=clone(obj[attr])
            }
            else{
                copy[attr] = obj[attr];
            }
        }
    }
    return copy;
}

function sum(vector){
    return vector.reduce(add, 0);
}
function add(a, b) {
    return a + b;
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function argmax(arr) {
    if (arr.length === 0) {
        return -1;
    }

    var max = arr[0];
    var maxIndex = [0];

    for (var i = 1; i < arr.length; i++) {
        if (arr[i] > max) {
            maxIndex = [i];
            max = arr[i];
        }
        else{
            if (arr[i] == max){
                maxIndex.push(i)
            }
        }
    }

    return maxIndex;
}

function test(){
    
    var condition=1
    
    meta_MDP.init(2)    
    available_actions=getActions(meta_MDP.state)
    click_action=available_actions[7]
    move_action=available_actions[1]
    
    s_next=getNextState(meta_MDP.state,click_action)
    
    PR_click=getPR(meta_MDP.state,click_action)
    PR_move=getPR(meta_MDP.state,move_action)
    
    action_nrs=[7,8,9,10,11,1];    
    actions = new Array()
    for (a in action_nrs){
        actions.push(available_actions[action_nrs[a]])
    }
    
    delay=computeDelay(meta_MDP.state,actions)
        
}

function test2(){
    
    var condition=1
    meta_MDP.init(2)    

    registerClick(2)
    registerClick(3)
    registerClick(4)
    registerClick(5)
    registerMove("up")
}

function recomputeDelays(){
    
    var temp_condition=condition
    
    condition=1
    
    var clicks_and_paths=loadJson("static/js/clicks_and_paths2.json")
    for (var t in clicks_and_paths){
        
        meta_MDP.init(clicks_and_paths[t].trialID)
        
        var move_times=JSON.parse(clicks_and_paths[t].actionTimes)
        var click_times=JSON.parse(clicks_and_paths[t].clickTimes)
        var clicks=JSON.parse(clicks_and_paths[t].clicks.replaceAll("'",""))
        var path=JSON.parse(clicks_and_paths[0].path)
        
        var delays= new Array()
        
        if (click_times.length>0){
            var first_click_before_move=0;
                        
            for (m in move_times){
                var move_time=move_times[m]

                var last_click_before_move=_.findLastIndex(click_times,function(x){return x<move_time})
                
                var clicks_before_move = clicks.slice(first_click_before_move,last_click_before_move+1)
                
                for (c in clicks_before_move){
                    registerClick(clicks_before_move[c])
                }
                
                var available_actions=getMoves(meta_MDP.locations[path[parseInt(m)]])
                
                for (var a in available_actions){
                    if (available_actions[a].move.next_state==path[parseInt(m)+1]){
                        var feedback=registerMove(available_actions[a].move.direction)
                        delays.push(feedback.delay)
                    }
                }
                
                first_click_before_move=last_click_before_move+1;

            }
        }
        clicks_and_paths[t].delays=delays;
        console.log("completed trial "+t+" of "+clicks_and_paths.length)
    }
    
    condition=temp_condition
    
    download(JSON.stringify(clicks_and_paths), 'clicks_and_paths.json', 'text/plain');

}

String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};

function download(text, name, type) {
    var a = document.createElement("a");
    var file = new Blob([text], {type: type});
    a.href = URL.createObjectURL(file);
    a.download = name;
    a.click();
}

function setDiff(A,B){
    return A.filter(x => B.indexOf(x) < 0 );
}