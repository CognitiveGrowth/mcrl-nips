###
jspsych-plane.coffee
Fred Callaway

An MDP mdp in which the participant plans flights to
maximize profit.

###

# coffeelint: disable=max_line_length
mdp = undefined

# KEYS =
#   # left: 37
#   # up: 38
#   # right: 39
#   # down: 40
#   # up: 'U'
#   # down: 'E'
#   # right: 'I'
#   # left: 'N'
#   up: 'I'
#   down: 'K'
#   right: 'L'
#   left: 'J'

# KEY_DESCRIPTION = """
# Navigate with
# <strong>J</strong> (left)
# <strong>I</strong> (up)
# <strong>K</strong> (down)
# <strong>L</strong> (right)
# """


jsPsych.plugins['graph'] = do ->

  KEYS = _.mapObject
    up: 'uparrow'
    down: 'downarrow',
    right: 'rightarrow',
    left: 'leftarrow',
    jsPsych.pluginAPI.convertKeyCharacterToKeyCode
  
  KEY_DESCRIPTION = """
  Navigate with the arrow keys.
  """
  
  RED = '#b00'
  GREEN = '#080'

  # ==== GLOBALS ==== #
  # a scaling parameter, determines size of drawn objects
  size = undefined
  # the fabric.Canvas object
  canvas = undefined

  fabric.Object::originX = fabric.Object::originY = 'center'
  fabric.Object::selectable = false
  fabric.Object::hoverCursor = 'plain'

  # =========================== #
  # ========= Helpers ========= #
  # =========================== #

  angle = (x1, y1, x2, y2) ->
    x = x2 - x1
    y = y2 - y1
    if x == 0
      ang = if y == 0 then 0 else if y > 0 then Math.PI / 2 else Math.PI * 3 / 2
    else if y == 0
      ang = if x > 0 then 0 else Math.PI
    else
      ang = if x < 0
        Math.atan(y / x) + Math.PI
      else if y < 0
        Math.atan(y / x) + 2 * Math.PI
      else Math.atan(y / x)
    return ang + Math.PI / 2

  polarMove = (x, y, ang, dist) ->
    x += dist * Math.sin ang
    y -= dist * Math.cos ang
    return [x, y]

  # Draw object on canvas.
  add = (obj) ->
    canvas.add obj
    return obj

  dist = (o1, o2) ->
    ((o1.left - o2.left) ** 2 + (o1.top - o2.top)**2) ** 0.5

  redGreen = (val) ->
    if val > 0
      GREEN
    else if val < 0
      RED
    else
      '#777'

  round = (x) ->
    (Math.round (x * 100)) / 100
    # 3


# ============================ #
# ========= GraphMDP ========= #
# ============================ #
  
  class GraphMDP
    constructor: (config) ->
      {
        @display  # html display element
        @block  # MDPBlock object
        @graph  # defines transition and reward functions
        @initialState
        @trialID
        @feedback=true
        @infoCost=PARAMS.info_cost
        @keys=KEYS
        @playerImage='/static/images/plane.png'
        @minTime=(if DEBUG then 5 else 45)
        lowerMessage=KEY_DESCRIPTION
      } = config

      meta_MDP.init(@trialID)

      @invKeys = _.invert @keys
      @data =
        minTime: @minTime  # minimum time before completing the trial
        infoCost: @infoCost  # cost of clicking on a state to learn its reward
        trialID: @trialID  # unique ID for the trial (i.e. reward structure)
        trialIndex: @block.trialCount  # order displayed in experiment
        score: 0  # total profit for this trial
        path: []  # states visited by participant, starting with initial (1)
        rt: []  # times between arriving at each state and the next key press
        actions: []  # sequence of actions e.g. ['left', 'left', 'up']
        clicks: []  # sequence of states clicked on (in order)
        actionTimes: []  # time in ms from beginning of trial of each action (keypress)
        clickTimes: []  # time in ms from beginning of trial of each click
        delays: []
        condition: condition
        feedback: @feedback
        
      @nMoves = 0

      @trialCounter = $('<div>',
        id: 'graph-msg-left'
        class: 'graph-header'
        html: "Round: #{@block.trialCount} / #{@block.timeline.length}").appendTo @display

      @message = $('<div>',
        id: 'graph-msg-center'
        class: 'graph-header'
        html: 'Time: <span id=graph-time/>').appendTo @display

      @scoreCounter = $('<div>',
        id: 'graph-msg-right',
        class: 'graph-header'
        html: 'Profit: <span id=graph-score/>').appendTo @display
          
      @canvas = $('<canvas>',
        id: 'graph-canvas',
      ).attr(width: 500, height: 500).appendTo @display

      @lowerMessage = $('<div>',
        id: 'graph-msg-bottom'
        html: lowerMessage or '&nbsp').appendTo @display

      # feedback element
      $('#jspsych-target').append """
      <div id="graph-feedback" class="modal">
        <div id="graph-feedback-content" class="modal-content">
          <h3>Default</h3>
        </div>
      </div>
      """
      
      mdp = this
      checkObj this
      console.log 'new GraphMDP', this


    # ---------- Responding to user input ---------- #

    # Called when a valid action is initiated via a key press.
    act: (s0, a) =>
      @nMoves += 1
      if @freeze then return
      @data.actions.push a
      @data.actionTimes.push (Date.now() - @initTime)

      result = @graph[s0].actions[a]
      [s1, _] = result
      r = @graph[s1].reward
      @addScore r

      s1g = @states[s1]
      @player.animate {left: s1g.left, top: s1g.top},
          duration: dist(@player, s0) * 4
          onChange: canvas.renderAll.bind(canvas)
          onComplete: =>
            @displayFeedback a, s1    
            #if condition is 1
            #  @displayFeedback a, s1
            #else
            #  @pause
            #  @arrive s1

            
    # Called when a state is clicked on.
    click: (s) =>
      if @freeze then return
      if s is "1" or s in @data.clicks
        return
      @data.clicks.push s
      @data.clickTimes.push (Date.now() - @initTime)
      @addScore (- @infoCost)
      @states[s].setLabel @graph[s].reward#.toFixed(2)
      registerClick(parseInt(s))

    # Called when the player arrives in a new state.
    arrive: (s) =>
      @data.path.push s

      # Listen for next action
      keys = (@keys[a] for a in (Object.keys @graph[s]['actions']))
      console.log 'arrive', s, keys
      if not keys.length
        @complete = true
        @checkFinished()
        return

      @keyListener = jsPsych.pluginAPI.getKeyboardResponse
        valid_responses: keys
        rt_method: 'date'
        persist: false
        allow_held_key: false
        callback_function: (info) =>
          action = @invKeys[info.key] #.toUpperCase()]

          @data.rt.push info.rt
          @act s, action


    # ---------- Starting the trial ---------- #
        
    run: =>
      @nMoves = 0;
      @buildMap()
      fabric.Image.fromURL @playerImage, ((img) =>
        @startTimer()
        @initPlayer img
        @initTime = Date.now()
        @arrive @initialState
      )

    startTimer: =>
      @timeLeft = @minTime
      intervalID = undefined

      tick = =>
        if @freeze then return
        @timeLeft -= 1
        $('#graph-time').html @timeLeft
        $('#graph-time').css 'color', (redGreen (-@timeLeft + .1))  # red if > 0
        if @timeLeft is 0
          window.clearInterval intervalID
          @checkFinished()
      
      $('#graph-time').html @timeLeft
      $('#graph-time').css 'color', (redGreen (-@timeLeft + .1))
      intervalID = window.setInterval tick, 1000

    initPlayer: (img) =>
      top = @states[@initialState].top
      left = @states[@initialState].left
      img.scale(0.35)
      # img.set('top', 0).set('left', 0)  # start at state 0
      img.set('top', top).set('left', left)
      add img
      img.set('top', top).set('left', left)
      canvas.renderAll()
      @player = img

    # Constructs the visual display.
    buildMap: =>
      size = 120
      width = 5 * size
      height = 5 * size
      @canvas.attr(width: width, height: height)
      canvas = new fabric.Canvas 'graph-canvas', selection: false

      @states = {}
      for name, {location} of @graph
        [x, y] = location
        @states[name] = add new State name, x, y,
          fill: if name is '1' then  '#fff' else '#bbb'

      for s0, {actions} of @graph
        for a, [s1, reward] of actions
          add new Edge @states[s0], @states[s1]

    addScore: (v) =>
      @data.score = round (@data.score + v)
      $('#graph-score').html '$' + @data.score.toFixed(2)
      $('#graph-score').css 'color', redGreen @data.score


    # ---------- ENDING THE TRIAL ---------- #

    # Creates a button allowing user to move to the next trial.
    endTrial: =>
      @lowerMessage.html """Press any key to continue.<br>"""
      @keyListener = jsPsych.pluginAPI.getKeyboardResponse
        valid_responses: []
        rt_method: 'date'
        persist: false
        allow_held_key: false
        callback_function: (info) =>
          @display.empty()
          jsPsych.finishTrial @data

      # # Continue by clicking button
      # @lowerMessage.html """Well done! Click Continue to move on.<br>"""
      # $('<button>')
      #   .addClass('btn btn-primary btn-lg')
      #   .text('Continue')
      #   .click (=>
      #     @display.empty()
      #     jsPsych.finishTrial @data)
      #   .appendTo @lowerMessage

    checkFinished: =>
      if @complete and @timeLeft > 0
        @lowerMessage.html """Waiting for the timer to expire..."""
      if @complete and @timeLeft <= 0
        @endTrial()
 
    displayFeedback: (a, s1) =>
      feedback = registerMove a
      console.log 'feedback', feedback
    
      if PARAMS.PR_type
        result =
          delay: Math.round feedback.delay
          planned_too_little: feedback.planned_too_little
          planned_too_much: feedback.planned_too_much
          information_used_correctly: feedback.information_used_correctly
      else
        result =
          delay: switch @nMoves
            when 1 then 8
            when 2 then 0
            when 3 then 1
          
      @data.delays.push(result.delay)
            
      redGreenSpan = (txt, val) ->
        "<span style='color: #{redGreen val}; font-weight: bold;'>#{txt}</span>"
      
      if PARAMS.PR_type
        head = do ->
          if result.planned_too_little
            if !result.planned_too_much
                redGreenSpan "You should have gathered more information!", -1            
            else
                redGreenSpan "You gathered too little relevant and too much irrelevant information!", -1            
          else
            if result.planned_too_much
                redGreenSpan "You considered irrelevant outcomes.", -1                    
            else
                redGreenSpan "You gathered enough information!", 1

        penalty = if result.delay then "<p>#{result.delay} second penalty</p>"
        info = \
          "Given the information you collected, your decision was " + \
          if result.information_used_correctly
            redGreenSpan 'optimal.', 1
          else
            redGreenSpan 'suboptimal.', -1

        msg = """
          <h3>#{head}</h3>
          <b>#{penalty}</b>
          #{info}
        """
      else
        msg = "Please wait "+result.delay+" seconds."  

      if @feedback and result.delay>=1        
          @freeze = true
          $('#graph-feedback').css display: 'block'

          $('#graph-feedback-content')
            # .css
            #   'background-color': if mistake then RED else GREEN
            #   color: 'white'
            .html msg

          setTimeout (=>
            @freeze = false
            $('#graph-feedback').css(display: 'none')
            @arrive s1
          ), result.delay * 1000
      else
            $('#graph-feedback').css(display: 'none')
            @arrive s1
    

  #  =========================== #
  #  ========= Graphics ========= #
  #  =========================== #

  class State extends fabric.Group
    constructor: (@name, left, top, config={}) ->
      left = (left + .5) * size
      top = (top + .7) * size
      conf =
        left: left
        top: top
        fill: '#bbbbbb'
        radius: size / 3.8
        hoverCursor: 'pointer'
        label: ''
      _.extend conf, config
      # @x = @left = left
      # @y = @top = top
      @on('mousedown', -> mdp.click @name)
      @circle = new fabric.Circle conf
      @label = new Text conf.label, left, top,
        fontSize: 20
        fill: '#44d'
      @radius = @circle.radius
      @left = @circle.left
      @top = @circle.top
      super [@circle, @label]

    setLabel: (txt) ->
      @label.setText '$' + txt
      @label.setFill (redGreen txt)
      @dirty = true


  class Edge extends fabric.Group
    # This is a group for legacy reasons. There
    # was once a label associated with an Edge.
    constructor: (c1, c2, conf={}) ->
      {
        reward=0
        pseudo=null
        label2=''
        spacing=8
        adjX=0
        adjY=0
      } = conf

      [x1, y1, x2, y2] = [c1.left + adjX, c1.top + adjY, c2.left + adjX, c2.top + adjY]

      @arrow = new Arrow(x1, y1, x2, y2,
                     c1.radius + spacing, c2.radius + spacing)

      super [@arrow]


  class Arrow extends fabric.Group
    constructor: (x1, y1, x2, y2, adj1=0, adj2=0) ->
      @ang = ang = (angle x1, y1, x2, y2)
      [x1, y1] = polarMove(x1, y1, ang, adj1)
      [x2, y2] = polarMove(x2, y2, ang, - (adj2+7.5))

      line = new fabric.Line [x1, y1, x2, y2],
        stroke: '#000'
        selectable: false
        strokeWidth: 3

      @centerX = (x1 + x2) / 2
      @centerY = (y1 + y2) / 2
      deltaX = line.left - @centerX
      deltaY = line.top - @centerY
      dx = x2 - x1
      dy = y2 - y1

      point = new (fabric.Triangle)(
        left: x2 + deltaX
        top: y2 + deltaY
        pointType: 'arrow_start'
        angle: ang * 180 / Math.PI
        width: 10
        height: 10
        fill: '#000')

      super [line, point]


  class Text extends fabric.Text
    constructor: (txt, left, top, config) ->
      txt = String(txt)
      conf =
        left: left
        top: top
        fontFamily: 'helvetica'
        fontSize: 14

      _.extend conf, config
      super txt, conf


  # ================================= #
  # ========= jsPsych stuff ========= #
  # ================================= #
  
  plugin =
    trial: (display_element, trial_config) ->
      display_element.empty()
      trial_config = jsPsych.pluginAPI.evaluateFunctionParameters(trial_config)
      trial_config['display'] = display_element

      # trial_config.mdp = loadJson trial_config.stim
      trial_config.block.trialCount += 1
      trial = new GraphMDP trial_config
      trial.run()

  return plugin

# ---
# generated by js2coffee 2.2.0