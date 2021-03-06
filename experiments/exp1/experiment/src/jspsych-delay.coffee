
jsPsych.plugins['delay'] = do ->
  plugin =
    trial: (display_element, trial_config) ->
      do display_element.empty
      trial_config = jsPsych.pluginAPI.evaluateFunctionParameters trial_config

      {duration} = trial_config

      display_element.append markdown """
        # Break

        Feel free to do whatever you'd like until the timer completes.
        Note that you still have to complete the entire HIT in one hour,
        so don't stay away too long!
      """
      $timer = $('<div>', class: 'timer').appendTo display_element
      $timer.html 'HELLO'

      start = do getTime
      seconds = 5
      minutes = 0
      hours = 0

      complete = ->
        # Continue by clicking button
        display_element.append $('<button>')
          .addClass('btn btn-primary btn-lg')
          .text('Continue')
          .click (->
            do display_element.empty
            jsPsych.finishTrial {rt: (do getTime) - start}
          )

      tick = ->
        seconds--
        if seconds < 0
          seconds = 59
          minutes--
          if minutes < 0
            minutes = 59
            hours--
            if hours < 0
              do complete
              return
        console.log 'here'
        $timer.html (if hours then (if hours > 9 then hours else '0' + hours) else '00') + ':' + (if minutes then (if minutes > 9 then minutes else '0' + minutes) else '00') + ':' + (if seconds > 9 then seconds else '0' + seconds)
        setTimeout(tick, 1000)
      do tick



  return plugin