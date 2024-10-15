let board_is_cleared = false
let board_is_legal = true

let board_goal = 8;
let queen_count = 0
let queenPositions = [];     
let wallPositions = [];
let squares = [];
const image_paths = ['resources/queen.png', 'resources/bad_queen.png', 'resources/wall.png']

// -- save these
let current_board_index = 0;
let all_queen_positions = [];

function createBoard(size, index) {
    const board = document.getElementById('chessboard');
    board.innerHTML = '';  

    const boardDimension = 600; 
    const squareSize = boardDimension / size;  

    board.style.gridTemplateColumns = `repeat(${size}, ${squareSize}px)`;
    board.style.gridTemplateRows = `repeat(${size}, ${squareSize}px)`;

    let isWhite = false;
	
	board_goal = board_dataset[index][1];
	queen_count = 0;
    // Initialize the board state and create the tiles
    for (let row = 0; row < size; row++) {
        queenPositions[row] = [];
		wallPositions[row] = [];
		squares[row] = [];
        for (let col = 0; col < size; col++) {
            const square = document.createElement('div');
            square.classList.add(isWhite ? 'white' : 'black');
            square.dataset.row = row;
            square.dataset.col = col;
            square.addEventListener('click', () => handleSquareClick(size, square, row, col));
			squares[row][col] = square;
            board.appendChild(square);			
			
			let idx = row * size + col;
			let shift = BigInt(1) << BigInt(63 - idx) ;
			
			queenPositions[row][col] = (all_queen_positions[index] & shift) !== BigInt(0) ? 1 : 0;
			if (queenPositions[row][col] == 1)
			{
				queen_count += 1;
			}
			wallPositions[row][col] = BigInt(board_dataset[index][0]) & shift;

            isWhite = !isWhite;
        }
		 isWhite = (size % 2 === 0) ? !isWhite : isWhite;
    }
	
	draw_walls(size);
	check_and_draw_queens(size);
	board_is_cleared = (board_is_legal && queen_count === board_goal);	
	updateDisplay();
}

function handleSquareClick(size, square, row, col) {	
	if (board_is_cleared || wallPositions[row][col]) {
		return;
	}
	
	let idx = row*size + col;
	if (queenPositions[row][col]) {
		queenPositions[row][col] = 0;
		all_queen_positions[current_board_index] &= ~(BigInt(1) << BigInt(63 - idx)); //Zero in the idx spot
		queen_count -= 1;
	}
	else {
		queenPositions[row][col] = 1;
		all_queen_positions[current_board_index] |= (BigInt(1) << BigInt(63 - idx)); //One in the idx spot
		queen_count += 1;
	}

	check_and_draw_queens(size);
	console.log("legality: " + board_is_legal);
	console.log("Queen count is equal" + queen_count === board_goal);
	console.log("Queen count: " + queen_count);
	console.log("Board goal: " + board_goal);
	board_is_cleared = (board_is_legal && queen_count === board_goal);
	updateDisplay();
    save();
}

// ---------------- Visuals
function draw_on_square(square, img_index) {
	const queenImage = document.createElement('img');
	queenImage.src = image_paths[img_index];
	queenImage.style.width = '100%'; 
	queenImage.style.height = '100%'; 
	queenImage.style.position = 'absolute'; 
	queenImage.style.top = '0';
	queenImage.style.left = '0';
	
	square.appendChild(queenImage)	
}

function handleNextClick() {
	if (current_board_index == board_dataset.length-1) {
		return;
	}
	current_board_index += 1;
	createBoard(8, current_board_index);
	save();
}

function handlePrevClick() { 
	if (current_board_index == 0) {
		return;
	}
	current_board_index -= 1;
	createBoard(8, current_board_index);
	save();
}

function updateDisplay() {
    document.getElementById('puzzleNumber').innerText = `Puzzle: ${current_board_index+1} / ${board_dataset.length}`;
    document.getElementById('boardGoal').innerText = `Place ${board_goal} queens safely!`;
	
    const successMessage = document.getElementById('success-message');
    
    if (board_is_cleared) {
        successMessage.style.display = 'block'; 
    } else {
        successMessage.style.display = 'none'; 
    }	
	
}

// ---------------- Board legality
function draw_walls(size,walls) {
	for (let row = 0; row < size; row++) {
		for (let col = 0; col < size; col++) {
			if (wallPositions[row][col]) {
				draw_on_square(squares[row][col], 2)
			}
		}
	}
}

function check_and_draw_queens(size) {	
	board_is_legal = true;
	for (let row = 0; row < size; row++) {
		for (let col = 0; col < size; col++) {
			if (wallPositions[row][col]) {
				continue;
			}
			
			const square = squares[row][col];
			
			const prev_image = square.querySelector('img')
			if (prev_image) {
				square.removeChild(prev_image);
			}			
			
			if (!queenPositions[row][col]) {
				continue;
			}
			let img_index = 0;
			if (!queen_is_legal(size,row,col)) {
					board_is_legal = false;
					img_index = 1;
			}
			
			draw_on_square(square, img_index);
		}
	}
}


function queen_is_legal(size, row, col) {	
	// -- Horizontal-right validity
	for (let j = col + 1; j < size; j++) { 	
		if (wallPositions[row][j]) {
			break;
		}
		else if (queenPositions[row][j]) {
			return false;
		}
	}
	// -- Horizontal-left validity
	for (let j = 1; j <= col; j++) { 	
		if (wallPositions[row][col-j]) {
			break;
		}
		else if (queenPositions[row][col-j]) {
			return false;
		}
	}	
	// -- Vertical down validity
	for (let i = row + 1; i < size; i++) {
		if (wallPositions[i][col]) {
			break;
		}
		else if (queenPositions[i][col]) {
			return false;
		}
	}
	// -- Vertical up validity
	for (let i = 1; i <= row; i++) {
		if (wallPositions[row-i][col]) {
			break;
		}
		else if (queenPositions[row-i][col]) {
			console.log("Oops!");
			return false;
		}
	}
	// -- Diagonal down-right validity
	for (let k = 1; k < size; k++) {
		if (row + k > size-1 || col + k > size-1 || wallPositions[row+k][col+k]) {
			break;
		}
		else if (queenPositions[row+k][col+k]) {
			return false;
		}
	}
	// -- Diagonal down-left validity
	for (let k = 1; k < size; k++) {
		if (row + k > size-1 || col - k < 0 || wallPositions[row+k][col-k]) {
			break;
		}
		else if (queenPositions[row+k][col-k]) {
			return false;
		}
	}
	// -- Diagonal up-right validity
	for (let k = 1; k < size; k++) {
		if (row - k < 0 || col + k > size-1 || wallPositions[row-k][col+k]) {
			break;
		}
		else if (queenPositions[row-k][col+k]) {
			return false;
		}		
	}
	// -- Diagonal up-left validity
	for (let k = 1; k < size; k++) {
		if (row - k < 0 || col - k < 0 || wallPositions[row-k][col-k]) {
			break;
		}
		else if (queenPositions[row-k][col-k]) {
			return false;
		}		
	}
	
	// -- Return true if all checks are passed
	return true
}


// --- Save/Load progress

function save() {
    localStorage.setItem('cB', current_board_index);
    localStorage.setItem('qP', JSON.stringify(all_queen_positions.map(pos => pos.toString()))); 
		
    console.log('Data saved:', current_board_index);	
	
}

function loadData() {
	console.log("loading data...");
    current_board_index = parseInt(localStorage.getItem('cB')) || 0;
	
	const stored_pos = localStorage.getItem('qP');
	if (stored_pos) {
		 const parsed_pos = JSON.parse(stored_pos);
		console.log("Reading existing positions!");
		all_queen_positions = parsed_pos.map(pos => BigInt(pos));
	}
	else {
		console.log("First time load!");
		all_queen_positions = Array(board_dataset.length).fill(0n);
	}

	console.log(all_queen_positions.length);
	console.log(all_queen_positions);
	console.log("loaded!");
}



window.onload = () => {
	loadData();
	
    createBoard(8, current_board_index);
	document.getElementById('nextButton').addEventListener('click', () => handleNextClick());	
	document.getElementById('prevButton').addEventListener('click', () => handlePrevClick());	
};