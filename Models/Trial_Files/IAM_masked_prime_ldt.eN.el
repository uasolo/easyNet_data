masked_prime_ldt:
cmd, iam reset
cmd, prime set (vocab column_rep Word string_representation) $prime
cmd, feature_level clamp prime
cmd, loop 5 cycle step
cmd, feature_level unclamp
cmd, (letter_level state) set_equal blank
cmd, (letter_level output) set_equal blank
cmd, target set (vocab column_rep Word string_representation) $target
cmd, feature_level clamp target
cmd, until (or lexical_decider (time later_than 100)) cycle step
cmd, ldt_file write prime target time lexical_decider
