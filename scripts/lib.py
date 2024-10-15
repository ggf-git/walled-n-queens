import subprocess
import re 
import itertools
import random

def run_scip():
    scip_command = ['scip', '-b', 'run.txt']  # Using batch script to run SCIP
    result = subprocess.run(scip_command, capture_output=True, text=True)

    if result.returncode != 0:
        print("Error running SCIP:", result.stderr)
        return None

    vars = []
    objective_value = -1
    solution_found = False
    for line in result.stdout.splitlines():
        if solution_found:
            if line == "":
                break
            cleaned_line = re.sub(r'\s+', ' ', line)
            parts = cleaned_line.split(' ')
            vars.append(parts[0])
            
        if 'objective value' in line:  # Detect solution section
            cleaned_line = re.sub(r'\s+', ' ', line)
            parts = cleaned_line.split(' ')
            objective_value = parts[2]
            solution_found = True
    
    return (objective_value, vars)

def write_blocked_tiles_txt(blocked_tiles):
    with open("blocked_tiles.txt", "w") as file:
        for tile in blocked_tiles:
            file.write(str(tile[0]) + "," + str(tile[1]) + "\n")

def get_all_nW_boards(b_size, n):
    board = list(itertools.product(range(b_size), repeat=2))
    comb = list(itertools.combinations(board, n))
    random.shuffle(comb)
    return comb
    
    
def coords_to_64bit(coords_list):
    res = 0
    for coords in coords_list:
        idx = 8*int(coords[0]) + int(coords[1])
        res = res | (1 << (63 - idx))
    return res
    
def queens_to_64bit(queens_sol):
    res = 0
    for queen in queens_sol:
        p = queen.split("#")
        row = int(p[1])
        col = int(p[2])
        idx = 8*row + col
        res = res | (1 << (63 - idx))
    return res    

def get_symmetry_group(board):
    res = set()
    
    res.add(tuple(board))
    res.add(tuple(reflect_vert(board)))
    res.add(tuple(reflect_hor(board)))
    res.add(tuple(reflect_diag(board)))
    res.add(tuple(reflect_anti_diag(board)))
    
    w = board
    for _ in range(3):
        w = rotate_90d(w)
        res.add(tuple(w))    
        res.add(tuple(reflect_vert(w)))
        res.add(tuple(reflect_hor(w)))
        res.add(tuple(reflect_diag(w)))
        res.add(tuple(reflect_anti_diag(w)))

    return res;
    
def rotate_90d(coords):
    return [(j, 7 - i) for i, j in coords]
    
def reflect_vert(coords):
    return [(i, 7-j) for i,j in coords]
    
def reflect_hor(coords):
    return [(7-i, j) for i,j in coords]
    
def reflect_diag(coords):
    return [(j,i) for i,j in coords]

def reflect_anti_diag(coords):
    return [(7-j,7-i) for i,j in coords]
    

def contains_child_board(board_set, candidate):
    for saved_b in board_set:
        if all(coord in candidate for coord in saved_b):
            return True
    return False
    
def run_scip_value_only():
    scip_command = ['scip', '-b', 'run.txt']  # Using batch script to run SCIP
    result = subprocess.run(scip_command, capture_output=True, text=True)

    if result.returncode != 0:
        print("Error running SCIP:", result.stderr)
        return None

    for line in result.stdout.splitlines():
        if 'objective value' in line:  # Detect solution section
            cleaned_line = re.sub(r'\s+', ' ', line)
            parts = cleaned_line.split(' ')
            return int(round(float(parts[2])))
    
    print("Objective value line not found!")
    return None
    
def count_unique_solutions(scip_output):
    write_counter_obj_txt(scip_output);

    scip_command = ['scip', '-b', 'count.txt']  # Using batch script to run SCIP
    result = subprocess.run(scip_command, capture_output=True, text=True)
    if result.returncode != 0:
        print("Error running SCIP:", result.stderr)
        return None

    for line in result.stdout.splitlines():
        if 'Feasible Solutions' in line:  # Detect solution section
            cleaned_line = re.sub(r'\s+', ' ', line)
            parts = cleaned_line.split(' ')
            return int(round(float(parts[3])))
    
    print("Solution count line not found!")
    return None
    

def write_counter_obj_txt(obj):
    with open("counter_obj.txt", "w") as file:
        file.write(str(obj))
    