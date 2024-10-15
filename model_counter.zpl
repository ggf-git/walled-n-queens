param n := 8 ;
set IDX := {0 .. n - 1} ;
set Board := IDX * IDX ;
set blocked_tiles := {read "blocked_tiles.txt" as "<1n,2n>"};
param value := read "counter_obj.txt" as "1n" use 1;


# -- Get all Row Partitions
set ROW_BLOCK[<i> in IDX] := { <r,c> in blocked_tiles with r == i } ;
param get_row_partition_idx[<i,j> in Board] := card({<r,c> in ROW_BLOCK[i] with r == i and c <= j}) ;
set ROW_PARTITIONS[<row,p_index> in Board] := { <i,j> in Board with i == row and get_row_partition_idx[i, j] == p_index} ;

# -- Get all Column Partitions
set COL_BLOCK[<j> in IDX] := { <r,c> in blocked_tiles with c == j } ;
param get_col_partition_idx[<i,j> in Board] := card({<r,c> in COL_BLOCK[j] with r <= i and c == j}) ;
set COL_PARTITIONS[<col,p_index> in Board] := { <i,j> in Board with j == col and get_col_partition_idx[i, j] == p_index} ;

# ----- Top left - Bottom Right Diagonals
# -- Get Partition for diagonal going from (0,0) to (n,n) AKA main TL - BR diagonal
set MAIN_DIAG_1_BLOCK := { <i,j> in blocked_tiles with i == j } ;
param get_main_diag_1_partition_idx[<d> in IDX] := card({<k,k> in MAIN_DIAG_1_BLOCK with k <= d}) ;
set MAIN_DIAG_1_PARTITIONS[<p_index> in IDX] := { <i,j> in Board with i == j and get_main_diag_1_partition_idx[i] == p_index } ;

# -- Get Partition for TL - BR diagonals above the main diagonal
set TLBR_UPPER_DIAG_BLOCK[<j> in IDX with j > 0] := { <k1,k2> in blocked_tiles with k1 < n and k2 == k1+j } ;
param get_tlbr_upper_diag_partition_idx[<i,j> in Board with j > i] := card({<r,c> in TLBR_UPPER_DIAG_BLOCK[j-i] with r <= i}) ;
set TLBR_UPPER_DIAG_PARTITIONS[<col,p_index> in Board with col > 0 and col < n-1] := { <i,j> in Board with j == i+col and get_tlbr_upper_diag_partition_idx[i,j] == p_index } ;

# -- Get Partition for TL - BR diagonals below the main diagonal
set TLBR_LOWER_DIAG_BLOCK[<i> in IDX with i > 0] := { <k1,k2> in blocked_tiles with k2 < n and k1 == k2+i } ;
param get_tlbr_lower_diag_partition_idx[<i,j> in Board with i > j] := card({<r,c> in TLBR_LOWER_DIAG_BLOCK[i-j] with c <= j}) ;
set TLBR_LOWER_DIAG_PARTITIONS[<row,p_index> in Board with row > 0 and row < n-1] := { <i,j> in Board with i == j+row and get_tlbr_lower_diag_partition_idx[i,j] == p_index } ;

# ----- Top Right - Bottom Left Diagonals
# -- Get Partition for diagonal going from (0,n-1) to (n-1, 0) (Top right - Bottom left diagonal) AKA main TR - BL column
set MAIN_DIAG_2_BLOCK := { <i,j> in blocked_tiles with i + j == n-1 } ;
param get_main_diag_2_partition_idx[<d> in IDX] := card({<k1,k2> in MAIN_DIAG_2_BLOCK with k2 == n - k1 - 1 and k1 <= d}) ;
set MAIN_DIAG_2_PARTITIONS[<p_index> in IDX] := { <i,j> in Board with i + j == n-1 and get_main_diag_2_partition_idx[i] == p_index } ;

# -- Get Partition for TR - BL diagonals above the main TR - BL diagonal
set TRBL_UPPER_DIAG_BLOCK[<k> in IDX] := { <k1,k2> in blocked_tiles with k1 + k2 == k} ;
param get_trbl_upper_diag_partition_idx[<i,j> in Board with i+j < n-1] := card({<r,c> in TRBL_UPPER_DIAG_BLOCK[i+j] with r >= i}) ; 
set TRBL_UPPER_DIAG_PARTITIONS[<row,p_index> in Board with row > 0 and row < n-1] := { <i,j> in Board with i+j == row and get_trbl_upper_diag_partition_idx[i,j] == p_index } ;


# -- Get Partition for TR - BL diagonals below the main TR - BL diagonal
set TRBL_LOWER_DIAG_BLOCK[<k> in IDX] := { <k1,k2> in blocked_tiles with k1 + k2 == n - 1 + k} ;
param get_trbl_lower_diag_partition_idx[<i,j> in Board with i+j > n-1] := card({<r,c> in TRBL_LOWER_DIAG_BLOCK[i+j-n+1] with c <= j}) ; 
set TRBL_LOWER_DIAG_PARTITIONS[<col,p_index> in Board with col > 0 and col < n-1] := { <i,j> in Board with i+j == n+col-1 and get_trbl_lower_diag_partition_idx[i,j] == p_index } ;


#do forall <col,p_index> in Board do print COL_PARTITIONS[col,p_index] ;
#do forall <p_index> in IDX do print MAIN_DIAG_1_PARTITIONS[p_index] ;
#do forall <p_index> in IDX do print MAIN_DIAG_2_PARTITIONS[p_index] ;
#do forall <col,p_index> in Board with col > 0 and col < n-1 do print TLBR_UPPER_DIAG_PARTITIONS[col, p_index];
#do forall <row,p_index> in Board with row > 0 and row < n-1 do print TLBR_LOWER_DIAG_PARTITIONS[row, p_index];
#do forall <row,p_index> in Board with row > 0 and row < n-1 do print TRBL_UPPER_DIAG_PARTITIONS[row, p_index];
#do forall <row,p_index> in Board with row > 0 and row < n-1 do print TRBL_LOWER_DIAG_PARTITIONS[row, p_index];

# ----- Binary variable representing if a queen is in a square or not.
var QUEEN[Board] binary ;

# ----- Constraints representing queen's attack paths (Only 1 Queen allowed per partitioned set)
subto OBJ:
    sum <i,j> in Board: QUEEN[i,j] == value ;

subto BLOCKED_IS_EMPTY: 
	forall <i,j> in blocked_tiles:
		QUEEN[i,j] == 0 ;

subto ROW_SAFE:
	forall <row, p_index> in Board:
		sum <i,j> in ROW_PARTITIONS[row, p_index]: QUEEN[i,j] <= 1 ;

subto COL_SAFE:
	forall <col, p_index> in Board:
		sum <i,j> in COL_PARTITIONS[col, p_index]: QUEEN[i,j] <= 1 ;

subto MAIN_TLBR_DIAG_SAFE:
	forall <p_index> in IDX:
		sum <i,j> in MAIN_DIAG_1_PARTITIONS[p_index]: QUEEN[i,j] <= 1 ;

subto TLBR_UPPER_DIAGS_SAFE:
	forall <col,p_index> in Board with col > 0 and col < n-1:
		sum <i,j> in TLBR_UPPER_DIAG_PARTITIONS[col,p_index]: QUEEN[i,j] <= 1 ;
		
subto TLBR_LOWER_DIAGS_SAFE:
	forall <row,p_index> in Board with row > 0 and row < n-1:
		sum <i,j> in TLBR_LOWER_DIAG_PARTITIONS[row,p_index]: QUEEN[i,j] <= 1 ;

subto MAIN_TRBL_DIAG_SAFE:
	forall <p_index> in IDX:
		sum <i,j> in MAIN_DIAG_2_PARTITIONS[p_index]: QUEEN[i,j] <= 1 ;

subto TRBL_UPPER_DIAGS_SAFE:
	forall <row,p_index> in Board with row > 0 and row < n-1:
		sum <i,j> in TRBL_UPPER_DIAG_PARTITIONS[row,p_index]: QUEEN[i,j] <= 1 ;

subto TRBL_LOWER_DIAGS_SAFE:
	forall <col,p_index> in Board with col > 0 and col < n-1:
		sum <i,j> in TRBL_LOWER_DIAG_PARTITIONS[col,p_index]: QUEEN[i,j] <= 1 ;

