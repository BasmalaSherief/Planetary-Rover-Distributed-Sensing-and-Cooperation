(define (domain planetary-rovers-design)
    (:requirements :typing :strips :equality :disjunctive-preconditions)

    (:types
        rover location sample - object
        navigator spectrometer - rover
        light-sample heavy-sample - sample
    )

    (:predicates
        (at ?r - rover ?l - location)
        (connected ?l1 ?l2 - location)
        
        ;; Sample base states
        (sample-at ?s - sample ?l - location)
        (analyzed ?s - sample)
        
        ;; Light Sample Delivery states
        (carrying-sample ?r - rover ?s - light-sample)
        (empty ?r - rover)
        (sample-delivered ?s - light-sample)
        
        ;; Heavy Sample Communication states (Boolean flags)
        (has-data ?r - navigator ?s - heavy-sample)
        (location-known ?sp - spectrometer ?s - heavy-sample ?l - location)
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

    ;; --- 2. LIGHT SAMPLE LOGIC ---
    (:action collect
        :parameters (?n - navigator ?s - light-sample ?loc - location)
        :precondition (and 
            (at ?n ?loc)
            (sample-at ?s ?loc)
            (empty ?n)
        )
        :effect (and
            (not (sample-at ?s ?loc))
            (carrying-sample ?n ?s)
            (not (empty ?n))
        )
    )

    (:action deliver
        :parameters (?n - navigator ?sp - spectrometer ?s - light-sample ?loc - location)
        :precondition (and 
            (at ?n ?loc)        ;; Distance threshold: must be at same location
            (at ?sp ?loc)
            (carrying-sample ?n ?s)
        )
        :effect (and
            (not (carrying-sample ?n ?s))
            (empty ?n)
            (sample-delivered ?s) ;; Meets the "or(sample-delivered)" precondition for analysis
            (sample-at ?s ?loc)   ;; The sample is now dropped at the spectro's feet
        )
    )

    ;; --- 3. HEAVY SAMPLE LOGIC ---
    (:action save_samplelocation
        :parameters (?n - navigator ?s - heavy-sample ?loc - location)
        :precondition (and 
            (at ?n ?loc)
            (sample-at ?s ?loc)
        )
        :effect (and
            (has-data ?n ?s) ;; The boolean flag is set to true
        )
    )

    (:action transmit_receive_comm
        :parameters (?n - navigator ?sp - spectrometer ?s - heavy-sample ?rendezvous - location ?sample-loc - location)
        :precondition (and 
            (at ?n ?rendezvous)       ;; Proximity threshold met
            (at ?sp ?rendezvous)
            (has-data ?n ?s)          ;; Sender has the boolean flag
            (sample-at ?s ?sample-loc) ;; The actual coordinate data being passed
        )
        :effect (and
            (not (has-data ?n ?s))    ;; Data transferred
            (location-known ?sp ?s ?sample-loc) ;; Spectrometer now knows where to go
        )
    )

    ;; --- 4. ANALYSIS ---
    (:action analysis
        :parameters (?sp - spectrometer ?s - sample ?loc - location)
        :precondition (and 
            (at ?sp ?loc)
            (or 
                ;; Condition A: It's a light sample that was delivered
                (and (sample-delivered ?s) (sample-at ?s ?loc))
                ;; Condition B: It's a heavy sample that the spectro traveled to
                (and (location-known ?sp ?s ?loc) (sample-at ?s ?loc))
            )
        )
        :effect (and
            (analyzed ?s)
        )
    )
)