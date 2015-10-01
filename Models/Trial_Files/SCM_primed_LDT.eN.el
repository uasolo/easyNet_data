primed_ldt:
reset,scm
cmd, prime set (vocab column_rep Word string_representation) $prime
cmd, fl clamp prime
cmd, loop 55 cycle step
cmd, (ll state) set_equal blank
cmd, (ll output) set_equal blank
cmd, (decision_layer state) set_equal blank
cmd, target set (vocab column_rep Word string_representation) $target
cmd, fl clamp target
cmd, until (or decision_obs (time later_than 300)) cycle step
cmd, ldt_file write prime target time decision_obs
