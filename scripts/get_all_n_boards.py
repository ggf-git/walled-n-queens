import lib
import sys
import pandas as pd

b_size = int(sys.argv[1])
n = int(sys.argv[2])
group_symmetries = bool(sys.argv[3])

print("CHECKING VALUE OF ALL " + str(n) + "W BOARDS")
print("GROUPING BY 90° SYMMETRIES: " + sys.argv[2]) 
nwall_boards = lib.get_all_nW_boards(b_size, n)

max_nwall_queens = -1
max_nwall_board = []

value_boards = {}
all_boards = []

checked_boards = set()


i = 0
for board in nwall_boards:
    walls_id = lib.coords_to_64bit(board)
        
    if group_symmetries and walls_id in checked_boards:
        continue
    
    checked_boards.update(lib.get_symmetry_group(board))
    
    lib.write_blocked_tiles_txt(board)
    scip_output = lib.run_scip()

    if scip_output:
        value = int(round(float(scip_output[0])))
        queens_id = lib.queens_to_64bit(scip_output[1])
        
        if value > max_nwall_queens:
            max_nwall_queens = value
            max_nwall_board = board 

        value_boards[value] = value_boards.get(value, 0) + 1
        board_row = {"Walls": walls_id, "Value": value, "Queens:": queens_id}
        all_boards.append(board_row)
    else:
        print(f"SCIP run {i} failed")

    i += 1
    
    if i % 100 == 0:
        print("Boards checked: " + str(i) + "/" + str(len(nwall_boards)))
        print("True boards checked: " + str(len(checked_boards)) + "/" + str(len(nwall_boards)))
        print("Max " + str(n) + "W queens: " + str(max_nwall_queens))
        print("Max " + str(n) + "W queen example board: " + str(max_nwall_board))
        for value in value_boards:
            print(f"There are {value_boards[value]} boards with value {value}. ({100 * value_boards[value] / i:.2f}%)")
        print("--------")


print("Total boards checked: " + str(i))

df = pd.DataFrame(all_boards)
df.to_csv("Analysis/" + str(n) + "-W Boards.csv", index=False)


print("---RUN COMPLETE!")
print("Total " + str(n) + "W boards: " + str(len(nwall_boards)))
print("True boards checked: " + str(len(checked_boards)) + "/" + str(len(nwall_boards)))
print("Max " + str(n) + "W queens: " + str(max_nwall_queens))
print("Max " + str(n) + "W queen example board: " + str(max_nwall_board))

for value in value_boards:
    print(f"There are {value_boards[value]} boards with value {value}. ({100 * value_boards[value] / i:.2f}%)")

