(define (problem latency-coop-scenario)
    (:domain planetary-rover-pddlplus)

    (:objects
        robot-nav - navigator
        robot-spectro - spectrometer
        
        base - location
        zone-alpha - location
        deep-crater - location
        
        boulder - heavy-sample
    )

    (:init
        (at robot-nav base)
        (at robot-spectro base)
        
        (sample-at boulder deep-crater)
        
        ;; Map Connections
        (connected base zone-alpha)
        (connected zone-alpha base)
        (connected zone-alpha deep-crater)
        (connected deep-crater zone-alpha)
        
        ;; --- PDDL+ Numeric Initializations ---
        
        ;; Comm setup
        (= (data-transferred boulder) 0.0)
        (= (data-size boulder) 10.0) ;; Takes 10 units of data to complete
        (= (transfer-rate) 2.0)      ;; Transfers 2 units per second (will take 5 seconds)
        
        ;; Distance threshold (they must be at the exact same location, distance = 0)
        (= (comm-threshold) 0.0)
        
        ;; Distance matrix (simplified)
        (= (loc-distance base base) 0.0)
        (= (loc-distance zone-alpha zone-alpha) 0.0)
        (= (loc-distance base zone-alpha) 50.0)
        (= (loc-distance zone-alpha base) 50.0)
    )

    (:goal
        (and
            (analyzed boulder)
        )
    )
)