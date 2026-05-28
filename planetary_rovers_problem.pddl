(define (problem dual-sample-mission)
    (:domain planetary-rovers-design)

    (:objects
        robot-nav - navigator
        robot-spectro - spectrometer
        
        base - location
        zone-alpha - location
        rock-bed - location
        deep-crater - location
        
        pebble - light-sample
        boulder - heavy-sample
    )

    (:init
        (at robot-nav base)
        (at robot-spectro base)
        (empty robot-nav)
        
        ;; Placements
        (sample-at pebble rock-bed)
        (sample-at boulder deep-crater)
        
        ;; Map Connections
        (connected base zone-alpha)
        (connected zone-alpha base)
        
        (connected zone-alpha rock-bed)
        (connected rock-bed zone-alpha)
        
        (connected zone-alpha deep-crater)
        (connected deep-crater zone-alpha)
    )

    (:goal
        (and
            (analyzed pebble)
            (analyzed boulder)
        )
    )
)