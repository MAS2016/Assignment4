; UVA/VU - Multi-Agent Systems
; Lecturers: T. Bosse & M.C.A. Klein
; Lab assistants: D. Formolo & L. Medeiros


; --- Assignment 4.1 - Template ---
; Please use this template as a basis for the code to generate the behaviour of your team of vacuum cleaners.
; However, feel free to extend this with any variable or method you think is necessary.


; --- Settable variables ---
; The following settable variables are given as part of the 'Interface' (hence, these variables do not need to be declared in the code):
;
; 1) dirt_pct: this variable represents the percentage of dirty cells in the environment.
;
; 2) num_agents: number of vacuum cleaner agents in the simularion.
;
; 3) vision_radius: distance (in terms of number of cells) that the agents can 'see'
; For instance, if this radius is 3, then agents will be able to observe dirt in a cell that is 3 cells away from their own location.


; --- Global variables ---
; The following global variables are given.
;
; 1) total_dirty: this variable represents the amount of dirty cells in the environment.
; 2) time: the total simulation time.
globals [total_dirty time colors color_others]


; --- Agents ---
; The following types of agent (called 'breeds' in NetLogo) are given.
;
; 1) vacuums: vacuum cleaner agents.
; 2) sensors: sensor for vacuum cleaner agents.
breed [vacuums vacuum]
breed [sensors sensor]


; --- Local variables ---
; The following local variables are given.
;
; 1) beliefs: the agent's belief base about locations that contain dirt
; 2) desire: the agent's current desire
; 3) intention: the agent's current intention
; 4) own_color: the agent's belief about its own target color
vacuums-own [beliefs desire intention own_color dirt_count]


; --- Setup ---
to setup
  clear-all
  set time 0
  setup-patches
  setup-vacuums
  setup-ticks
end


; --- Main processing cycle ---
to go
  ; This method executes the main processing cycle of an agent.
  ; For Assignment 4.1, this involves updating desires, beliefs and intentions, and executing actions (and advancing the tick counter).
  update-desires
  update-beliefs
  update-intentions
  execute-actions
  tick
  if count patches with [pcolor != white] > 0 ; report time to complete the task
    [set time ticks]
end


; --- Setup patches ---
to setup-patches
  ; In this method you may create the environment (patches), using colors to define cells with various types of dirt.
  set colors []                          ; select a number of colors equal to a number of agents

  loop
  [
    let col (random 14) * 10 + 5         ; choose between a random color
    set colors lput col colors           ; put color as first item in list
    set colors remove-duplicates colors
    if length colors = num_agents        ; if number of colors in list equals number of agents
    [
      ask patches
      [
        ifelse random 100 < dirt_pct     ; then, choose randomly between colours if the patch is dirty
        [
          let patchCol random num_agents
          set pcolor item patchCol colors
        ]
        [set pcolor white]
      ]
      stop
    ]
  ]

end


; --- Setup vacuums ---
to setup-vacuums
  ; In this method you may create the vacuum cleaner agents.
  create-vacuums num_agents [                                    ; create vacuums
    setxy (random-xcor) (random-ycor)                            ; with random starting positions
    let col random length colors                                 ; and a random color
    set color item col colors
    set own_color item col colors
    set dirt_count count patches with [pcolor = item col colors] ; count the number of initial dirty cells in color of agent
    set colors remove-item col colors
    set beliefs []
  ]
end


; --- Setup ticks ---
to setup-ticks
  ; In this method you may start the tick counter.
  reset-ticks
end


; --- Update desires ---
to update-desires
  ; You should update your agent's desires here.
  ; At the beginning your agent should have the desire to 'clean all the dirt'.
  ; If it realises that there is no more dirt, its desire should change to something like 'stop and turn off'.
  ask vacuums[
    ifelse ticks > 0 and dirt_count = 0 ; if simulation is running and no more dirt in color of agent is present
      [
      set desire "stop and turn off"    ; then the agent desires to stop
      set color black
      ]
      [set desire "clean all the dirt"] ; if not, the agent desires to clean
  ]
end

; --- Update beliefs ---
to update-beliefs
 ; You should update your agent's beliefs here.
 ; Please remember that you should use this method whenever your agents changes its position.

 ; belief about
 ; - own colour             ; not yet
 ; - colour of other agents ; not yet
 ; - dirty locations        ; check

 ask vacuums
 [
   let vac self
   let col [color] of vac

   ask sensors with [color = col]                                  ; ask sensors with color of agent
   [
    if pcolor = col                                                ; if sensor is on a dirt
      [
        let p [patch-here] of self
        ask vac
        [
          set beliefs lput p beliefs                               ; put location of dirt in belief base
          set beliefs remove-duplicates beliefs                    ; remove possible duplicates
          set beliefs sort-by [distance ?1 < distance ?2] beliefs  ; sort beliefs by distance from agent (in ascending order)
        ]
      ]
   ]
 ]

end


to update-intentions
  ; You should update your agent's intentions here.
  ; The agent's intentions should be dependent on its beliefs and desires.
  ; intentions:
  ; - observe       ;check
  ; - move to dirt  ;check
  ; - clean dirt    ;check
  ; - send message  ;not yet
  ; - none          ;check

  ask vacuums [
    if desire = "clean all the dirt"[       ; if agents wants to clean
      ifelse not empty? beliefs             ; if agent has beliefs
      [
        ifelse intention = patch-here       ; if intention is current patch
          [set intention "clean this dirt"] ; he intends to clean this dirt
          [set intention first beliefs]     ; if intention is not the current patch, he intends to move to the nearest dirt
      ]
      [set intention "observe"]             ; if agent has no beliefs about dirt, he intends to observe
    ]

    if desire = "stop and turn off"         ; if agent desires to stop
       [set intention "none"]               ; he intends nothing
  ]
end


; --- Execute actions ---
to execute-actions
  ; Here you should put the code related to the actions performed by your agent:
  ; moving, cleaning, and (actively) looking around.
  ; Please note that your agents should perform only one action per tick!

  ask vacuums [move]
  ask vacuums [observe]
  ask vacuums [clean]

end

; TO DO:
; method voor moving
; method voor cleaning
; method voor rondkijken
; belief system opbouwen (lokaal en globaal?)
; - belief system alleen voor eigen soort dirt per agent

; method for moving (intentions: observe, move, clean)
to move
  ask vacuums
  [
    if is-patch? intention                         ; if intention is to move to dirt
      [ face intention                             ; face and move to dirt
        forward 0.5 ]

    ifelse intention = "observe" and can-move? 0.5 ; if intention is to observe and agent can move
      [forward 0.5]                                ; move
      [
        if intention != "none"                     ; if intention is to move or observe or the agent cannot move
        [set heading random 360]                   ; face a random direction
      ]
  ]
end


; method for cleaning
to clean
  if intention = "clean this dirt"                 ; if intention is to clean
    [
    set pcolor white                               ; clean dirt
    set beliefs remove-item 0 beliefs              ; remove it from the belief base
    set dirt_count dirt_count - 1                  ; and substract 1 from total dirt in color of agent that is left to clean
    ]
end

;method for observing
to observe

  if intention != "none"                           ; if agent has an intention
  [
    let vac self
    let col [color] of vac

    ask sensors with [color = col]                 ; kill all sensors in color of agent
    [
      die
    ]
    ask patches in-radius vision_radius            ; on patches in agent's vision radius
    [
      sprout-sensors 1                             ; create sensors
      [
        create-link-with vac                       ; and link them with the agent
        set shape "dot"
        set color col
      ]
    ]
    ask my-links [set color col]                   ; color the links between sensors and agent
  ]
end
