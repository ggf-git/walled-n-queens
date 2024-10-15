param n := 7 ;
param q := 16 ;
set IDX := {0 .. n - 1} ;
set Board := IDX * IDX ;

# ----- Binary variable representing if a queen is in a square or not.
var QUEEN[Board] binary ;
var BLOCKED[Board] binary ;

subto OBJ:
    sum <i,j> in Board: BLOCKED[i,j] == 33 ;

subto QUEEN_COUNT:
    sum <i,j> in Board: QUEEN[i,j] == q ;

subto BLOCKED_IS_EMPTY: 
	forall <i,j> in Board:
		QUEEN[i,j] + BLOCKED[i,j] <= 1 ;

subto ROW_SAFETY:
    forall <row> in IDX:
        forall <col1,col2> in Board with col1 < col2: 
            (sum <k> in IDX with k >= col1 and k <= col2: QUEEN[row,k]) <= 1 + (sum <k> in IDX with k > col1 and k < col2: BLOCKED[row,k]) ;

subto COL_SAFETY:
    forall <col> in IDX:
        forall <row1,row2> in Board with row1 < row2: 
            (sum <k> in IDX with k >= row1 and k <= row2: QUEEN[k,col]) <= 1 + (sum <k> in IDX with k > row1 and k < row2: BLOCKED[k,col]) ;

subto DIAG_SAFETY_1:
    forall <idx> in IDX:
        forall <m1,m2> in Board with m1 < m2:
            (sum <k> in {0.. n-1-idx} with k >= m1 and k <= m2: QUEEN[idx+k,k]) <= 1 + (sum <k> in {0.. n-1-idx} with k > m1 and k < m2: BLOCKED[idx+k,k]) ;
            
subto DIAG_SAFETY_2:
    forall <idx> in IDX:
        forall <m1,m2> in Board with m1 < m2:
            (sum <k> in {0.. n-1-idx} with k >= m1 and k <= m2: QUEEN[k,idx+k]) <= 1 + (sum <k> in {0.. n-1-idx} with k > m1 and k < m2: BLOCKED[k,idx+k]) ;
            
subto DIAG_SAFETY_3:
    forall <idx> in IDX:
        forall <m1,m2> in Board with m1 < m2:
            (sum <k> in {0..idx} with k >= m1 and k <= m2: QUEEN[k,idx-k]) <= 1 + (sum <k> in {0.. idx} with k > m1 and k < m2: BLOCKED[k,idx-k]) ;
            
subto DIAG_SAFETY_4:
    forall <idx> in IDX:
        forall <m1,m2> in Board with m1 < m2:
            (sum <k> in {0..idx} with k >= m1 and k <= m2: QUEEN[n-1-k, n-1-idx+k]) <= 1 + (sum <k> in {0.. idx} with k > m1 and k < m2: BLOCKED[n-1-k, n-1-idx+k]) ;    
            