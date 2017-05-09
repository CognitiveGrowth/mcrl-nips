###
jspsych-plane.coffee
Fred Callaway

An MDP mdp in which the participant plans flights to
maximize profit.

###

# coffeelint: disable=max_line_length
mdp = undefined


jsPsych.plugins['graph'] = do ->

  PRINT = (args...) -> console.log args...
  NULL = (args...) -> null
  LOG_INFO = PRINT
  LOG_DEBUG = PRINT

  KEYS = _.mapObject
    up: 'uparrow'
    down: 'downarrow',
    jsPsych.pluginAPI.convertKeyCharacterToKeyCode

  KEY_DESCRIPTION = """
  Navigate with the up and down arrow keys.
  """

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
      '#080'
    else if val < 0
      '#b00'
    else
      '#888'

  round = (x) ->
    (Math.round (x * 100)) / 100


# ============================ #
# ========= GraphMDP ========= #
# ============================ #
  
  class GraphMDP
    constructor: (config) ->
      {
        @display  # html display element
        @_block  # MDPBlock object
        @graph  # defines transition and reward functions
        @initial
        @width
        @depth
        @pr_freq
        @returns=null
        @pseudo=null
        @trialID=null
        @keys=KEYS
        @playerImage='static/images/plane.png'
        trial
        _json
        lowerMessage=KEY_DESCRIPTION
      } = config

      checkObj this
      console.log 'returns', @returns
      @invKeys = _.invert @keys
      @data =
        trial: trial
        env: _json
        pseudo_rewards: @pseudo._json
        pr_freq: @pr_freq
        returns: @returns
        trialID: @trialID
        trialIndex: @_block.trialCount
        score: 0
        stars: 0
        rewards: []
        prs: []
        path: []
        rt: []
        actions: []
        actionTimes: []
        # clicks: []
        # clickTimes: []

      @trialCounter = $('<div>',
        id: 'graph-msg-left'
        class: 'graph-header'
        html: "Trial: #{@_block.trialCount + 1} / #{@_block.timeline.length}").appendTo @display

      @message = $('<div>',
        id: 'graph-msg-center'
        class: 'graph-header'
        html: '<span id=graph-stars/>').appendTo @display
      @addStars null

      @scoreCounter = $('<div>',
        id: 'graph-msg-right',
        class: 'graph-header'
        html: 'Profit: <span id=graph-score/>').appendTo @display
      @addScore null
          
      @canvas = $('<canvas>',
        id: 'graph-canvas',
      ).attr(width: 500, height: 500).appendTo @display

      @lowerMessage = $('<div>',
        id: 'graph-msg-bottom'
        html: lowerMessage or '&nbsp'
      ).css('padding-top': '30px').appendTo @display
      
      mdp = this
      LOG_INFO 'new GraphMDP', this


    # ---------- Responding to user input ---------- #

    # Called when a valid action is initiated via a key press.
    handleKey: (s0, a) =>
      LOG_DEBUG 'handleKey', s0, a
      @data.actions.push a
      @data.actionTimes.push (Date.now() - @initTime)

      [s1, r] = @graph[s0][a]
      @addScore r

      s1g = @states[s1]
      @player.animate {left: s1g.left, top: s1g.top},
          duration: dist(@player, s0) * 4
          onChange: canvas.renderAll.bind(canvas)
          onComplete: =>
            @arrive s1

    # Called when a state is clicked on.
    handleClick: (s) =>

    # Called when the player arrives in a new state.
    arrive: (s) =>
      LOG_DEBUG 'arrive', s
      @data.path.push s
      @updatePseudo s

      # Listen for next action
      keys = (@keys[a] for a in (Object.keys @graph[s]))
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
          action = @invKeys[info.key]
          LOG_DEBUG 'key', info.key
          @data.rt.push info.rt
          @handleKey s, action

    updatePseudo: (s) ->
      if not @pseudo
        return
      if @nextPseudo?
        pr = @nextPseudo[s]
        if pr?
          @addStars pr
        else
          return  # haven't reached the next pseudo-reward

      # Compute new pseudo-rewards.
      @nextPseudo = {}
      pseudo = @pseudo[s]
      for name, state of @states
        pr = pseudo[name]
        if pr?
          @nextPseudo[name] = pr
          if pr != 0
            state.setLabel (pr)
            # state.setFill (redGreen pr)
          else
            state.setLabel ''
        else
          state.setLabel ''

      canvas.renderAll()
    


    # ---------- Starting the trial ---------- #

    run: =>
      LOG_DEBUG 'run'
      @buildMap()
      fabric.Image.fromURL @playerImage, ((img) =>
        @initPlayer img
        @initTime = Date.now()
        @arrive @initial
      )

    initPlayer: (img) =>
      LOG_DEBUG 'initPlayer'
      top = @states[@initial].top
      left = @states[@initial].left
      img.scale(0.3)
      # img.set('top', 0).set('left', 0)  # start at state 0
      img.set('top', top).set('left', left)
      add img
      img.set('top', top).set('left', left)
      canvas.renderAll()
      @player = img

    # Constructs the visual display.
    buildMap: =>
      LOG_DEBUG 'buildMap'
      locate = (s) ->
        [d, w] = s.split('_')
        d = parseInt d
        w = parseInt w
        adj = if d % 2 then 0.5 else 0
        [d, w - adj + 0.5]

      size = 120
      width = (@depth) * size
      height = (@width + .5) * size
      @canvas.attr(width: width, height: height)
      canvas = new fabric.Canvas 'graph-canvas', selection: false

      @states = {}
      for s, choices of @graph
        [x, y] = locate s
        @states[s] = (add new State s, x, y)

      for s0, choices of @graph
        for action, [s1, reward] of choices
          add new Edge @states[s0], @states[s1],
            reward: reward

    addScore: (v) =>
      if v?
        @data.rewards.push v
        @data.score = round (@data.score + v)
      $('#graph-score').html '$' + @data.score
      $('#graph-score').css 'color', redGreen @data.score


    addStars: (v) =>
      if v?
        @data.stars += v
        @data.prs.push v
      $('#graph-stars').html @data.stars + '⭐'
      # $('#graph-stars').css 'color', redGreen @data.stars



    # ---------- ENDING THE TRIAL ---------- #

    # Creates a button allowing user to move to the next trial.
    endTrial: =>
      @lowerMessage.html """<b>Press any key to continue.</br>"""
      @keyListener = jsPsych.pluginAPI.getKeyboardResponse
        valid_responses: []
        rt_method: 'date'
        persist: false
        allow_held_key: false
        callback_function: (info) =>
          @display.empty()
          jsPsych.finishTrial @data

    checkFinished: =>
      if @complete
        @endTrial()


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
        radius: size / 4
        label: ''
      _.extend conf, config
      # @x = @left = left
      # @y = @top = top
      @on('mousedown', => mdp.handleClick @name)
      @circle = new fabric.Circle conf
      @label = new Text conf.label, left, top,
        fontSize: size / 6
        fill: '#44d'
      @radius = @circle.radius
      @left = @circle.left
      @top = @circle.top
      super [@circle, @label]

    setLabel: (txt) ->
      if txt
        @label.setText txt + '⭐'
        @label.setFill (redGreen txt)
      else
        @label.setText ''
      @dirty = true


  class Edge extends fabric.Group
    constructor: (c1, c2, conf={}) ->
      {
        reward
        pseudo=null
        label2=''
        spacing=8
        adjX=0
        adjY=0
      } = conf

      [x1, y1, x2, y2] = [c1.left + adjX, c1.top + adjY, c2.left + adjX, c2.top + adjY]

      @arrow = new Arrow(x1, y1, x2, y2,
                     c1.radius + spacing, c2.radius + spacing)

      ang = (@arrow.ang + Math.PI / 2) % (Math.PI * 2)
      if 0.5 * Math.PI <= ang <= 1.5 * Math.PI
        ang += Math.PI
      
      # [labX, labY] = [x1 * 0.65 + x2 * 0.35,
      #                 y1 * 0.65 + y2 * 0.35]

      [labX, labY] = polarMove(x1, y1, angle(x1, y1, x2, y2), size*0.5)

      txt = "$#{reward}"
      @label = new Text txt, labX, labY,
        angle: (ang * 180 / Math.PI)
        fill: redGreen reward
        fontSize: size / 6
        textBackgroundColor: 'white'

      # if label2
      #   [labX, labY] = polarMove(labX, labY, ang, -20)
      #   lab = new Text label2, labX, labY,
      #     angle: (ang * 180 / Math.PI)
      #     fill: '#f88'

      super [@arrow, @label]



  class Arrow extends fabric.Group
    constructor: (x1, y1, x2, y2, adj1=0, adj2=0) ->
      @ang = ang = (angle x1, y1, x2, y2)
      [x1, y1] = polarMove(x1, y1, ang, adj1)
      [x2, y2] = polarMove(x2, y2, ang, - (adj2+7.5))

      line = new fabric.Line [x1, y1, x2, y2],
        stroke: '#555'
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
        fill: '#555')

      super [line, point]


  class Text extends fabric.Text
    constructor: (txt, left, top, config) ->
      txt = String(txt)
      conf =
        left: left
        top: top
        fontFamily: 'helvetica'
        fontSize: size / 8

      _.extend conf, config
      super txt, conf


  # ================================= #
  # ========= jsPsych stuff ========= #
  # ================================= #
  
  plugin =
    trial: (display_element, trialConfig) ->
      trialConfig = jsPsych.pluginAPI.evaluateFunctionParameters(trialConfig)
      trialConfig['display'] = display_element
      
      _.extend(trialConfig, trialConfig.env)
      console.log 'trialConfig', trialConfig

      display_element.empty()
      trial = new GraphMDP trialConfig
      trial.run()
      trialConfig._block.trialCount += 1

  return plugin

# ---
# generated by js2coffee 2.2.0