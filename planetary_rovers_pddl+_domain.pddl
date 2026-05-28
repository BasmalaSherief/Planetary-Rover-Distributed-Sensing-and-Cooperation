(define (domain planetary-rover-pddlplus)
    (:requirements :typing :numeric-fluents :time :continuous-effects :disjunctive-preconditions)

    (:types
        rover location sample - object
        navigator spectrometer - rover
        light-sample heavy-sample - sample
    )

    (:predicates
        (at ?r - rover ?l - location)
        (connected ?l1 ?l2 - location)
        (sample-at ?s - sample ?l - location)
        (analyzed ?s - sample)
        
        ;; Q1 States
        (has-data ?n - navigator ?s - heavy-sample)
        (location-known ?sp - spectrometer ?s - heavy-sample ?l - location)
        
        ;; Q2 PDDL+ State
        (is-transmitting ?n - navigator ?sp - spectrometer ?s - heavy-sample)
    )

    (:functions
        ;; Q2 Continuous Data Variables
        (data-transferred ?s - heavy-sample)
        (data-size ?s - heavy-sample)
        (transfer-rate)
        
        ;; Map & Threshold Variables
        (loc-distance ?l1 - location ?l2 - location)
        (comm-threshold)
    )

    ;; --- 1. MOBILITY ---
    (:action move
        :parameters (?r - rover ?from - location ?to - location)
        :precondition (and 
            (at ?r ?from) 
            (connected ?from ?to)
        )
        :effect (and
            (not (at ?r ?from))
            (at ?r ?to)
        )
    )

    ;; --- 2. DATA ACQUISITION ---
    (:action save_samplelocation
        :parameters (?n - navigator ?s - heavy-sample ?loc - location)
        :precondition (and 
            (at ?n ?loc)
            (sample-at ?s ?loc)
        )
        :effect (and
            (has-data ?n ?s)
        )
    )

    ;; --- 3. PDDL+ CONTINUOUS COMMUNICATION BLOCK ---
    
    ;; A. The discrete action to begin the transmission
    (:action start-transmit
        :parameters (?n - navigator ?sp - spectrometer ?s - heavy-sample ?loc - location)
        :precondition (and 
            (at ?n ?loc) 
            (at ?sp ?loc) 
            (has-data ?n ?s)
            (not (is-transmitting ?n ?sp ?s))
        )
        :effect (and 
            (is-transmitting ?n ?sp ?s)
        )
    )

    ;; B. The Continuous Process: Models the data latency/delay over time
    (:process data-latency
        :parameters (?n - navigator ?sp - spectrometer ?s - heavy-sample)
        :precondition (and 
            (is-transmitting ?n ?sp ?s)
        )
        :effect (and 
            ;; Data increases continuously as time (#t) passes
            (increase (data-transferred ?s) (* #t (transfer-rate)))
        )
    )

    ;; C. The Success Event: Fires automatically when the data finishes transferring
    (:event transfer-complete
        :parameters (?n - navigator ?sp - spectrometer ?s - heavy-sample ?sample-loc - location)
        :precondition (and 
            (is-transmitting ?n ?sp ?s)
            (>= (data-transferred ?s) (data-size ?s))
            (sample-at ?s ?sample-loc)
        )
        :effect (and 
            (not (is-transmitting ?n ?sp ?s))
            (not (has-data ?n ?s))
            (location-known ?sp ?s ?sample-loc)
        )
    )

    ;; D. The Failure Event: Fires if a rover moves away and breaks the distance threshold
    (:event data-loss
        :parameters (?n - navigator ?sp - spectrometer ?s - heavy-sample ?loc1 - location ?loc2 - location)
        :precondition (and 
            (is-transmitting ?n ?sp ?s)
            (at ?n ?loc1)
            (at ?sp ?loc2)
            ;; If the distance between the two rovers becomes greater than the threshold
            (> (loc-distance ?loc1 ?loc2) (comm-threshold))
        )
        :effect (and 
            (not (is-transmitting ?n ?sp ?s))
            (assign (data-transferred ?s) 0) ;; Data is corrupted/lost and resets
        )
    )

    ;; --- 4. ANALYSIS ---
    (:action analyze
        :parameters (?sp - spectrometer ?s - heavy-sample ?loc - location)
        :precondition (and 
            (at ?sp ?loc)
            (location-known ?sp ?s ?loc)
            (sample-at ?s ?loc)
        )
        :effect (and
            (analyzed ?s)
        )
    )
)