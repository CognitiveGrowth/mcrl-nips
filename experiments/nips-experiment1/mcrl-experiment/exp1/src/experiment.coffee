###
experiment.coffee
Fred Callaway

Demonstrates the jspsych-mdp plugin

###
# coffeelint: disable=max_line_length, indentation

# conditions: 1 = optimal delays, optimal message; 0 = fixed delays, no message; 2 = optimal delays, simple message; 3 = fixed delays, optimal message
#             4 = delays based on object-level PRs, simple message; 5 = delays based on object-level PRs, optimal message, 6 = delay based on feature-based meta-level PRs, simple message
DEBUG = true
console.log condition
if DEBUG
  console.log """
  X X X X X X X X X X X X X X X X X
   X X X X X DEBUG  MODE X X X X X
  X X X X X X X X X X X X X X X X X
  """
  condition = 6
else
  
    condition = 6
    
    console.log """
  # =============================== #
  # ========= NORMAL MODE ========= #
  # =============================== #
  """
    
# Globals.
psiturk = new PsiTurk uniqueId, adServerLoc, mode
params = undefined
blocks = undefined

do ->  # big closure to prevent polluting global namespace

  #  ========================= #
  #  ========= SETUP ========= #
  #  ========================= #

  # expData = do ->
  #   result = $.ajax
  #     dataType: 'json'
  #     url: "/static/json/condition_#{condition}.json"
  #     async: false
  #   return result.responseJSON

  expData = loadJson 'static/json/condition_1.json'
  trials = expData.trials
  params = expData.params
    
  if condition<6
    params.PR_type = 1 #based on full-observation policy
  
  if condition>=6
    params.PR_type = 2 #feature-based approximation
  
if condition<=6
    params.time_cost_is_low = true
    params.time_cost_is_high = false

if condition>6
    params.time_cost_is_low = false
    params.time_cost_is_high = true

    
    
  psiturk.recordUnstructuredData 'params', params
  # blocks = expData.blocks

  # $(window).resize -> checkWindowSize 900, 700, $('#jspsych-target')
  # $(window).resize()


  #  ======================== #
  #  ========= TEXT ========= #
  #  ======================== #

  # These functions will be executed by the jspsych plugin that
  # they are passed to. String interpolation will use the values
  # of global variables defined in this file at the time the function
  # is called.

  text =
    debug: -> if DEBUG then "`DEBUG`" else ''


  # ================================= #
  # ========= BLOCK CLASSES ========= #
  # ================================= #

  class Block
    constructor: (config) ->
      _.extend(this, config)
      @block = this  # allows trial to access its containing block for tracking state
      if @init?
        @init()

  class TextBlock extends Block
    type: 'text'
    cont_key: ['space']

  class QuizLoop extends Block
    loop_function: (data) ->
      console.log 'data', data
      for c in data[data.length].correct
        if not c
          return true
      return false

  class MDPBlock extends Block
    type: 'graph'
    init: ->
      @trialCount = 0


  #  ============================== #
  #  ========= EXPERIMENT ========= #
  #  ============================== #

  debug_slide = new Block
    type: 'html'
    url: 'test.html'

  if condition is 0 # 0 = fixed delays, no message
      instructions = new Block
        type: "instructions"
        pages: [
          markdown """
            # Instructions #{text.debug()}

            In this game, you are in charge of flying an aircraft. As shown below, you will begin in the central location. The arrows show which actions are available in each location. Note that once you have made a move you cannot go back; you can only move forward along the arrows.
            There are eight possible final destinations labelled 1-8 in the image below. On your way there, you will visit two intermediate locations. <b>Every location you visit will add or subtract money to your account</b>, and your task is to earn as much money as possible. <b>To find out how much money you earn or lose in a location, you have to click on it.</b> You can uncover the value of as many or as few locations as you wish.

            <p><div align="center"><img src="static/js/images/instruction_images/Slide1.png" width=600></div></p>

            <p>To navigate the airplane, use the arrows (the example above is non-interactive). You can uncover the value of a location at any time. Click "Next" to proceed.</p>
          """

          markdown """
            # Instructions

            You will play the game for 8 rounds. The value of every location will change from each round to the next. At the begining of each round, the value of every location will be hidden, and you will only discover the value of the locations you click on. The example below shows the value of every location, just to give you an example of values you could see if you clicked on every location. <b>Every time you click a circle to observe its value, you pay a fee of 10 cents.</b> In the example below, the current profit is $-1.60 because 16 locations have been inspected and none of their rewards has been collected yet. Each time you move to a location, your profit will be adjusted. If you move to a location with a hidden value, your profit will still be adjusted according to the value of that location. There will be a 3.18-second delay period after the first move in each round.

            <p><div align="center"><img src="static/js/images/instruction_images/Slide2.png" width=600></div></p>
          """

          markdown """
            # Instructions

            There are two more important things to understand:
            <p>1. <b>You must spend at least 45 seconds on each round.</b> As shown below, there will be a countdown timer. You won’t be able to proceed to the next round before the countdown has finished, but you can take as much time as you like afterwards.</p>
            <p>2. <b>You will earn <u>REAL MONEY</u> for your flights.</b> Specifically, one of the 8 rounds will be chosen at random and you will receive 5% of your earnings in that round as a bonus payment.</p>

            <p><div align="center"><img src="static/js/images/instruction_images/Slide3.png" width=600></div></p>

            <p> You may proceed to take an entry quiz, or go back to review the instructions.</p>
          """
        ]
        show_clickable_nav: true
    else if condition is 1 # conditions: 1 = optimal delays, optimal message
      instructions = new Block
        type: "instructions"
        pages: [
          markdown """
            # Instructions #{text.debug()}

            In this game, you are in charge of flying an aircraft. As shown below, you will begin in the central location. The arrows show which actions are available in each location. Note that once you have made a move you cannot go back; you can only move forward along the arrows.
            There are eight possible final destinations labelled 1-8 in the image below. On your way there, you will visit two intermediate locations. <b>Every location you visit will add or subtract money to your account</b>, and your task is to earn as much money as possible. <b>To find out how much money you earn or lose in a location, you have to click on it.</b> You can uncover the value of as many or as few locations as you wish.

            <p><div align="center"><img src="static/js/images/instruction_images/Slide1.png" width=600></div></p>

            <p>To navigate the airplane, use the arrows (the example above is non-interactive). You can uncover the value of a location at any time. Click "Next" to proceed.</p>
          """

          markdown """
            # Instructions

            You will play the game for 8 rounds. The value of every location will change from each round to the next. At the begining of each round, the value of every location will be hidden, and you will only discover the value of the locations you click on. The example below shows the value of every location, just to give you an example of values you could see if you clicked on every location. <b>Every time you click a circle to observe its value, you pay a fee of 10 cents.</b> In the example below, the current profit is $-1.60 because 16 locations have been inspected and none of their rewards has been collected yet. Each time you move to a location, your profit will be adjusted. If you move to a location with a hidden value, your profit will still be adjusted according to the value of that location.

            <p><div align="center"><img src="static/js/images/instruction_images/Slide2.png" width=600></div></p>
          """
            
          markdown """
            # Instructions

            <b>You will receive feedback about your planning. This feedback will help you learn how to make better decisions.</b> After each flight, if you did not plan optimally, a feedback message will apear. This message will tell you two things: <p>1) Whether you observed too few relevant values or if you observed irrelevant values (values of locations that you can\'t fly to).</p><p>2) Whether you flew along the best route given your current location and the information you had about the values of other locations.</p><p>In the example below, not enough relevant values were observed, and as a result there is a 15 second timeout penalty. <b>The duration of the timeout penalty is proportional to how poorly you planned your route:</b> the more money you could have earned from observing more values and/or choosing a better route, the longer the delay. The second feedback in the example below indicates the plane was flown along the best route, given the limited information available. If you perform optimally, no feedback will be shown and you can proceed immediately.</p>

            <p><div align="center"><img src="static/js/images/instruction_images/Slide4.png" width=600></div></p>
          """

          markdown """
            # Instructions

            There are two more important things to understand:
            <p>1. <b>You must spend at least 45 seconds on each round.</b> As shown below, there will be a countdown timer. You won’t be able to proceed to the next round before the countdown has finished, but you can take as much time as you like afterwards.</p>
            <p>2. <b>You will earn <u>REAL MONEY</u> for your flights.</b> Specifically, one of the 8 rounds will be chosen at random and you will receive 5% of your earnings in that round as a bonus payment.</p>

            <p><div align="center"><img src="static/js/images/instruction_images/Slide3.png" width=600></div></p>

            <p> You may proceed to take an entry quiz, or go back to review the instructions.</p>
          """
        ]
        show_clickable_nav: true
    else if condition is 2 || condition is 4 || condition is 6 # 2 = optimal delays, simple message; 4 = delays based on object-level PRs, simple message
      instructions = new Block
        type: "instructions"
        pages: [
          markdown """
            # Instructions #{text.debug()}

            In this game, you are in charge of flying an aircraft. As shown below, you will begin in the central location. The arrows show which actions are available in each location. Note that once you have made a move you cannot go back; you can only move forward along the arrows.
            There are eight possible final destinations labelled 1-8 in the image below. On your way there, you will visit two intermediate locations. <b>Every location you visit will add or subtract money to your account</b>, and your task is to earn as much money as possible. <b>To find out how much money you earn or lose in a location, you have to click on it.</b> You can uncover the value of as many or as few locations as you wish.

            <p><div align="center"><img src="static/js/images/instruction_images/Slide1.png" width=600></div></p>

            <p>To navigate the airplane, use the arrows (the example above is non-interactive). You can uncover the value of a location at any time. Click "Next" to proceed.</p>
          """

          markdown """
            # Instructions

            You will play the game for 8 rounds. The value of every location will change from each round to the next. At the begining of each round, the value of every location will be hidden, and you will only discover the value of the locations you click on. The example below shows the value of every location, just to give you an example of values you could see if you clicked on every location. <b>Every time you click a circle to observe its value, you pay a fee of 10 cents.</b> In the example below, the current profit is $-1.60 because 16 locations have been inspected and none of their rewards has been collected yet. Each time you move to a location, your profit will be adjusted. If you move to a location with a hidden value, your profit will still be adjusted according to the value of that location.

            <p><div align="center"><img src="static/js/images/instruction_images/Slide2.png" width=600></div></p>
          """
            
          markdown """
            # Instructions

            <b>You will receive feedback about your planning. This feedback will help you learn how to make better decisions.</b> After each flight, if you did not plan optimally, a feedback message will apear. In the example below, planning was suboptimal, and as a result there is a 15 second timeout penalty. <b>The duration of the timeout penalty is proportional to how poorly you planned your route:</b> the more money you could have earned from observing more values and/or choosing a better route, the longer the delay. If you perform optimally, no feedback will be shown and you can proceed immediately.</p>

            <p><div align="center"><img src="static/js/images/instruction_images/Slide5.png" width=600></div></p>
          """

          markdown """
            # Instructions

            There are two more important things to understand:
            <p>1. <b>You must spend at least 45 seconds on each round.</b> As shown below, there will be a countdown timer. You won’t be able to proceed to the next round before the countdown has finished, but you can take as much time as you like afterwards.</p>
            <p>2. <b>You will earn <u>REAL MONEY</u> for your flights.</b> Specifically, one of the 8 rounds will be chosen at random and you will receive 5% of your earnings in that round as a bonus payment.</p>

            <p><div align="center"><img src="static/js/images/instruction_images/Slide3.png" width=600></div></p>

            <p> You may proceed to take an entry quiz, or go back to review the instructions.</p>
          """
        ]
        show_clickable_nav: true
    else if condition is 3 # 3 = fixed delays, optimal message
      instructions = new Block
        type: "instructions"
        pages: [
          markdown """
            # Instructions #{text.debug()}

            In this game, you are in charge of flying an aircraft. As shown below, you will begin in the central location. The arrows show which actions are available in each location. Note that once you have made a move you cannot go back; you can only move forward along the arrows.
            There are eight possible final destinations labelled 1-8 in the image below. On your way there, you will visit two intermediate locations. <b>Every location you visit will add or subtract money to your account</b>, and your task is to earn as much money as possible. <b>To find out how much money you earn or lose in a location, you have to click on it.</b> You can uncover the value of as many or as few locations as you wish.

            <p><div align="center"><img src="static/js/images/instruction_images/Slide1.png" width=600></div></p>

            <p>To navigate the airplane, use the arrows (the example above is non-interactive). You can uncover the value of a location at any time. Click "Next" to proceed.</p>
          """

          markdown """
            # Instructions

            You will play the game for 8 rounds. The value of every location will change from each round to the next. At the begining of each round, the value of every location will be hidden, and you will only discover the value of the locations you click on. The example below shows the value of every location, just to give you an example of values you could see if you clicked on every location. <b>Every time you click a circle to observe its value, you pay a fee of 10 cents.</b> In the example below, the current profit is $-1.60 because 16 locations have been inspected and none of their rewards has been collected yet. Each time you move to a location, your profit will be adjusted. If you move to a location with a hidden value, your profit will still be adjusted according to the value of that location. There will be a 3.18-second delay period after the first move in each round.

            <p><div align="center"><img src="static/js/images/instruction_images/Slide2.png" width=600></div></p>
          """

          markdown """
            # Instructions

            <b>You will receive feedback about your planning. This feedback will help you learn how to make better decisions.</b> After each flight, if you did not plan optimally, a feedback message will apear. This message will tell you two things: <p>1) Whether you observed too few relevant values or if you observed irrelevant values (values of locations that you can\'t fly to).</p><p>2) Whether you flew along the best route given your current location and the information you had about the values of other locations.</p><p>The second feedback in the example below indicates the plane was flown along the best route, given the limited information available. If you perform optimally, no feedback will be shown and you can proceed immediately.</p>

            <p><div align="center"><img src="static/js/images/instruction_images/Slide6.png" width=600></div></p>
          """
            
          markdown """
            # Instructions

            There are two more important things to understand:
            <p>1. <b>You must spend at least 45 seconds on each round.</b> As shown below, there will be a countdown timer. You won’t be able to proceed to the next round before the countdown has finished, but you can take as much time as you like afterwards.</p>
            <p>2. <b>You will earn <u>REAL MONEY</u> for your flights.</b> Specifically, one of the 8 rounds will be chosen at random and you will receive 5% of your earnings in that round as a bonus payment.</p>

            <p><div align="center"><img src="static/js/images/instruction_images/Slide3.png" width=600></div></p>

            <p> You may proceed to take an entry quiz, or go back to review the instructions.</p>
          """
        ]
        show_clickable_nav: true

    if condition is 0 # 0 = fixed delays, no message
      quiz = new Block
        preamble: -> markdown """
          # Quiz
        """
        type: 'survey-multi-choice'  # note: I've edited this jspysch file
        questions: [
          """
            How many flights are there per round?
          """
          """
            True or false: The hidden values will change each time I start a new round.
          """
          """
            How much does it cost to observe each hidden value?
          """
          """
            How many hidden values am I allowed to observe in each round?
          """
          """
            Which statement is TRUE?
          """
        ]
        options: [
          ['1', '2', '3', '4']
          ['True', 'False']
          ['$0.00', '$0.10', '$0.25', '$0.50']
            ['At most 1', 'At most 5', 'At most 10', 'At most 15', 'As many or as few as I wish']
            ['My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), but these earnings aren\'t real money.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), but these earnings aren\'t real money.']
        ]
        required: [true, true, true, true, true]
        correct: ['3', 'True', '$0.10', 'As many or as few as I wish', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.']
        on_mistake: (data) ->
          alert """You got at least one question wrong. We'll send you back to the
                   instructions and then you can try again."""
    else if condition is 1 # 1 = optimal delays, optimal message
      quiz = new Block
        preamble: -> markdown """
          # Quiz
        """
        type: 'survey-multi-choice'  # note: I've edited this jspysch file
        questions: [
          """
            How many flights are there per round?
          """
          """
            True or false: The hidden values will change each time I start a new round.
          """
          """
            How much does it cost to observe each hidden value?
          """
          """
            How many hidden values am I allowed to observe in each round?
          """
          """
            Which statement is TRUE?
          """
          """
            What does the feedback teach me?
          """
        ]
        options: [
          ['1', '2', '3', '4']
          ['True', 'False']
          ['$0.00', '$0.10', '$0.25', '$0.50']
            ['At most 1', 'At most 5', 'At most 10', 'At most 15', 'As many or as few as I wish']
            ['My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), but these earnings aren\'t real money.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), but these earnings aren\'t real money.']
            ['Whether I observed the rewards of relevant locations.', 'Whether I chose the move that was best according to the information I had.', 'The duration of the delay is proportional to how much more money I could have earned by planning and deciding better.', 'All of the above.']
        ]
        required: [true, true, true, true, true, true]
        correct: ['3', 'True', '$0.10', 'As many or as few as I wish', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'All of the above.', 'True']
        on_mistake: (data) ->
          alert """You got at least one question wrong. We'll send you back to the
                   instructions and then you can try again."""
    else if condition is 2 || condition is 4 || condition is 6 # 2 = optimal delays, simple message; 4 = delays based on object-level PRs, simple message
      quiz = new Block
        preamble: -> markdown """
          # Quiz
        """
        type: 'survey-multi-choice'  # note: I've edited this jspysch file
        questions: [
          """
            How many flights are there per round?
          """
          """
            True or false: The hidden values will change each time I start a new round.
          """
          """
            How much does it cost to observe each hidden value?
          """
          """
            How many hidden values am I allowed to observe in each round?
          """
          """
            Which statement is TRUE?
          """
          """
            True of false: The duration of the delay is proportional to how much more money I could have earned by planning and deciding better.
          """
        ]
        options: [
          ['1', '2', '3', '4']
          ['True', 'False']
          ['$0.00', '$0.10', '$0.25', '$0.50']
            ['At most 1', 'At most 5', 'At most 10', 'At most 15', 'As many or as few as I wish']
            ['My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), and I will actually be paid the earnings from one of the 8 rounds.', 'My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), but these earnings aren\'t real money.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), but these earnings aren\'t real money.']
            ['True', 'False']
        ]
        required: [true, true, true, true, true,true]
        correct: ['3', 'True', '$0.10', 'As many or as few as I wish', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.','True']
        on_mistake: (data) ->
          alert """You got at least one question wrong. We'll send you back to the
                   instructions and then you can try again."""
    else if condition is 3 # 3 = fixed delays, optimal message
      quiz = new Block
        preamble: -> markdown """
          # Quiz
        """
        type: 'survey-multi-choice'  # note: I've edited this jspysch file
        questions: [
          """
            How many flights are there per round?
          """
          """
            True or false: The hidden values will change each time I start a new round.
          """
          """
            How much does it cost to observe each hidden value?
          """
          """
            How many hidden values am I allowed to observe in each round?
          """
          """
            Which statement is TRUE?
          """
          """
            What does the feedback teach me?
          """
        ]
        options: [
          ['1', '2', '3', '4']
          ['True', 'False']
          ['$0.00', '$0.10', '$0.25', '$0.50']
            ['At most 1', 'At most 5', 'At most 10', 'At most 15', 'As many or as few as I wish']
            ['My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), but these earnings aren\'t real money.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), but these earnings aren\'t real money.']
            ['Whether I observed the rewards of relevant locations.', 'Whether I chose the move that was best according to the information I had.', 'All of the above.']
        ]
        required: [true, true, true, true, true, true]
        correct: ['3', 'True', '$0.10', 'As many or as few as I wish', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will actually be paid 5% the earnings from one of the 8 rounds.', 'All of the above.']
        on_mistake: (data) ->
          alert """You got at least one question wrong. We'll send you back to the
                   instructions and then you can try again."""


  instruct_loop = new Block
    timeline: [instructions, quiz]
    loop_function: (data) ->
      for c in data[1].correct
        if not c
          return true  # try again
      psiturk.finishInstructions()
      psiturk.saveData()
      return false


    # The JSON file contains 12 planning problems (where the myopic first move
    # is optimal  for problems 10-12 but suboptimal for problems 1-9). I think
    # it will be best to shuffle the order of these trials across
    # participants. The shuffling should be done such that the first move with
    # the highest reward is optimal for 2 of the 8 training problems and 1 of
    # the 4 test problems. This can be accomplished by putting 2 of the last
    # three trials in the training block and the remaining one in the test
    # block.
  #myopic = _.shuffle trials[-3...]
  #nonmyopic = _.shuffle trials[...-3]

  main = new MDPBlock
    timeline: _.shuffle trials #nonmyopic[...6] .concat myopic[...2]

  delay = new Block
    type: 'delay'
    duration: 60
    
  #retention = new MDPBlock
  #    feedback: false
  # timeline: _.shuffle (nonmyopic[6...] .concat myopic[2...])
    
    
  finish = new Block
    type: 'button-response'
    stimulus: -> markdown """
      # This completes the HIT

      One or your trials has been randomly selected and we will pay you 5% of your profit on that trial as a bonus. You will be awarded a bonus of $#{calculateBonus().toFixed(2)}
      """
    is_html: true
    choices: ['Submit hit']
    button_html: '<button class="btn btn-primary btn-lg">%choice%</button>'

  # finish = new Block
  #   type: 'text'
  #   text: -> markdown """
  #     # This completes the HIT

  #     One or your profits was randomly selected. You will be awarded a bonus of $#{calculateBonus().toFixed(2)}

  #     """


      # $('<button>')
      #   .addClass('btn btn-primary btn-lg')
      #   .text('Continue')
      #   .click (=>
      #     @display.empty()
      #     jsPsych.finishTrial @data)
      #   .appendTo @lowerMessage


  if DEBUG
    experiment_timeline = [
      # instructions
      #delay
      # debug_slide
      # instruct_loop
      main
      #retention
      finish
    ]
  else
    experiment_timeline = [
      instruct_loop
      main
      #retention
      finish
    ]



  # ================================================ #
  # ========= START AND END THE EXPERIMENT ========= #
  # ================================================ #

  # bonus is the score on a random trial.
  BONUS = undefined
  calculateBonus = ->
    if DEBUG then return 0
    if BONUS?
      return BONUS
    data = jsPsych.data.getTrialsOfType 'graph'
    BONUS = 0.05 * Math.max 0, (_.sample data).score
    psiturk.recordUnstructuredData 'final_bonus', BONUS
    return BONUS
    
    # TODO: perhaps we should sample a few and take the median to
    # reduce the chance of someone randomly getting a low bonus
    # when they generally performed well. Or maybe just give them
    # the median.
  
  reprompt = null
  save_data = ->
    psiturk.saveData
      success: ->
        console.log 'Data saved to psiturk server.'
        if reprompt?
          window.clearInterval reprompt
        psiturk.computeBonus('compute_bonus', psiturk.completeHIT)
      error: -> prompt_resubmit

  prompt_resubmit = ->
    $('#jspsych-target').html """
      <h1>Oops!</h1>
      <p>
      Something went wrong submitting your HIT.
      This might happen if you lose your internet connection.
      Press the button to resubmit.
      </p>
      <button id="resubmit">Resubmit</button>
    """
    $('#resubmit').click ->
      $('#jspsych-target').html 'Trying to resubmit...'
      reprompt = window.setTimeout(prompt_resubmit, 10000)
      save_data()

  jsPsych.init
    display_element: $('#jspsych-target')
    timeline: experiment_timeline
    # show_progress_bar: true

    on_finish: ->
      if DEBUG
        jsPsych.data.displayData()
      else
        save_data()

    on_data_update: (data) ->
      console.log 'data', data
      psiturk.recordTrialData data

