ldt:
reset,scm
cmd, stimulus set (vocab column_rep Word string_representation) $stimulus
cmd, fl clamp stimulus
cmd, until (or decision_obs (time later_than 300)) cycle step
cmd, ldt_file write stimulus time decision_obs
