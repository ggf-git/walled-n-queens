import lib
import random
import sys


b_size = int(sys.argv[1])
saved_boards = []
all_saved_board_symmetries = {}
checked_boards = set()

for n in range(1,5):
    nwall_boards = lib.get_all_nW_boards(b_size, n)
    print("boards generated for n: " + str(n))
    for board in nwall_boards:
        if board in checked_boards:
            continue;
        print("Board:" + str(board))
        
        symmetry_group = lib.get_symmetry_group(board)
        checked_boards.update(symmetry_group)
        
        lib.write_blocked_tiles_txt(board)
        scip_output = lib.run_scip_value_only()
        
        if scip_output:
            # -- Update all saved symmetries dict if first time obj value is found
            if scip_output not in all_saved_board_symmetries:
                all_saved_board_symmetries[scip_output] = set()
                
            # -- Check if a more minimal board with the same value is already saved
            elif lib.contains_child_board(all_saved_board_symmetries[scip_output], board):
                continue;
             
            # -- Count if there are more than 1 unique solutions
            sol_count = lib.count_unique_solutions(scip_output)
            
            if sol_count == 1:
                board_id = lib.coords_to_64bit(board)
                saved_boards.append([board_id, scip_output])
                all_saved_board_symmetries[scip_output].update(symmetry_group)
                print("Unique! Saving... Total saved: " + str(len(saved_boards)));
                if len(saved_boards) >= 1000:
                    break;
    if len(saved_boards) >= 1000:
        break;
                

random.shuffle(saved_boards)
with open('interesting_puzzles.txt', 'w') as f:
    f.write(str(saved_boards).replace(' ', ''))  