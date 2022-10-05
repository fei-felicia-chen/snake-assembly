# color definition:
.eqv BLACK	0x00000000
.eqv RED	0x00ff0000
.eqv GREEN	0x0000ff00
.eqv BLUE	0x000000ff
.eqv YELLOW	0x00ffff00
.eqv BROWN	0x00994c00
.eqv GRAY	0x00f0f0f0
.eqv WHITE	0x00ffffff

# tile definition
.eqv EMPTY	BLACK
.eqv SNAKE	WHITE
.eqv FOOD	YELLOW
.eqv RED_PILL	RED
.eqv BLUE_PILL	BLUE
.eqv WALL	BROWN

# Direction definition
.eqv DIR_RIGHT	0
.eqv DIR_DOWN	1
.eqv DIR_LEFT	2
.eqv DIR_UP  3

# game state definition
.eqv STATE_NORMAL	0
.eqv STATE_PAUSE	1
.eqv STATE_RESTART	2
.eqv STATE_EXIT		3

# some constants for buffer
.eqv WIDTH	64
.eqv HEIGHT	32
.eqv DISPLAY_BUFFER_SIZE	0x2000
.eqv SNAKE_BUFFER_SIZE		0x2000

# initial postion of the snake
.eqv INIT_HEAD_X	32
.eqv INIT_HEAD_Y	16
.eqv INIT_TAIL_X	31
.eqv INIT_TAIL_Y	16

# initial length of the snake
.eqv INIT_LENGTH	2

# maximum number of pills
.eqv MAX_NUM_PILLS	10


.data
displayBuffer:	.space	DISPLAY_BUFFER_SIZE	# 64x32 display buffer. Each pixel takes 4 bytes.
snakeSegment:	.space	SNAKE_BUFFER_SIZE	# Array to store the offsets of the snake segments in the display buffer.
						# E.g., head_offset, 2nd_segment_offset, ..., tail_offset
						# Each offset takes 4 bytes.
snakeLength:	.word	INIT_LENGTH		# length of the snake
headX:		.word	INIT_HEAD_X		# head position x
headY:		.word	INIT_HEAD_Y		# head position y
numPills:	.word	0	# number of pills (red and blue)
direction:	.word	0	# moving direction of the snake head:
				#	0: right
				#	1: down
				#	2: left
				#	3: up
state:		.word	0	# game state:
				#	0: normal
				#	1: pause
				#	2: retstart
				#	3: exit
score:		.word	0	# score in the game. increase by 1 everying time eating a regular food
msgScore:	.asciiz "Score: "
.align 2
timeInterval:	.word   100
incSpeed:	.float 0.833333
decSpeed:	.float 1.25

mapfile:	.asciiz "mapfile2.txt"
readbuff:	.space 2150

.text
main:
	jal initGame
gameLoop:
	li $v0, 32
	lw $a0, timeInterval
	syscall
	
	lui	$t1, 0xffff            		# $t1 = 0xFFFF0000

	lw 	$t0, state			# check current state
	beq	$t0, STATE_PAUSE, paused	# stay paused if state is pause
	lw	$t4, 0($t1)            		# load from the input control register
	andi    $t4, $t4, 0x0001       		# reset (clear) all bits except LSB
	beqz    $t4, main.normal		# if not ready, then loop back
	lw    	$t5, 4($t1)            		# load word in $t5
	beq     $t5, $t6, main.normal
	beqz    $t5, main.normal        	# normal
	beq     $t5, 'w', up            	# move to appropriate position
	beq     $t5, 'a', left
	beq     $t5, 's', down
	beq     $t5, 'd', right
	beq     $t5, 'q', quit            	# trigger appropriate state
	beq     $t5, 'r', restart
	beq     $t5, 'p', pause

paused:
	lw	$t4, 0($t1)            		# load from the input control register
	andi    $t4, $t4, 0x0001       		# reset (clear) all bits except LSB
	beqz    $t4, paused			# if not ready, then loop back // stay paused
	lw    	$t5, 4($t1)            		# load word in $t5
	beq     $t5, 'p', continue

up:
    	la      $t0, direction			
    	li      $t1, DIR_UP
    	li	$t2, DIR_DOWN
    	lw	$t4, 0($t0)
    	beq	$t2, $t4, next			# check current direction
    	sw      $t1, 0($t0)			# change direction
    	li      $t6, 'w'
    	j       next    

left:
	la      $t0, direction			
    	li	$t1, DIR_LEFT
    	li	$t2, DIR_RIGHT
    	lw	$t4, 0($t0)
    	beq	$t2, $t4, next			# check current direction
    	sw    	$t1, 0($t0)			# change direction
    	li    	$t6, 'a'
    	j    	next

down:
    	la    	$t0, direction			
    	li    	$t1, DIR_DOWN
    	li	$t2, DIR_UP
    	lw	$t4, 0($t0)
    	beq	$t2, $t4, next			# check current direction
    	sw    	$t1, 0($t0)			# change direction
    	li    	$t6, 's'
    	j    	next
    
right:
    	la    	$t0, direction			
    	li    	$t1, DIR_RIGHT
    	li	$t2, DIR_LEFT
    	lw	$t4, 0($t0)
    	beq	$t2, $t4, next			# check current direction
    	sw    	$t1, 0($t0)			# change direction
    	li    	$t6, 'd'
    	j     	next

quit:
    	la    	$t0, state			# change state variable
    	li    	$t1, STATE_EXIT
    	sw    	$t1, 0($t0)
    	j    	main.exit

restart:
    	la    	$t0, state			# change state variable
    	li    	$t1, STATE_RESTART
    	sw    	$t1, 0($t0)
    	j    	main.restart

pause:
    	la    	$t0, state			# change state variable
    	li    	$t1, STATE_PAUSE
    	sw    	$t1, 0($t0)
    	j    	main.pause

continue:
    	la    	$t0, state			# change state variable
    	li    	$t1, STATE_NORMAL
    	sw    	$t1, 0($t0)
    	j    	main.normal
    	
next:
	
	lw $t0, state
	beq $t0, STATE_NORMAL, main.normal
	beq $t0, STATE_PAUSE, main.pause
	beq $t0, STATE_RESTART, main.restart
	j main.exit
main.normal:
	jal updateDisplay	
	j gameLoop
main.pause:
	j gameLoop
main.restart:
	jal initGame
	j gameLoop	
main.exit:
	la $a0, msgScore
	li $v0, 4
	syscall
	lw $a0, score
	li $v0, 1
	syscall
	li $v0, 10
	syscall
	
	
# void initGame()
initGame:
	sub $sp, $sp, 4
	sw $ra, ($sp)
	
	la $a0, displayBuffer
	li $a1, DISPLAY_BUFFER_SIZE
	jal clearBuffer
	
	jal initMap
	
	# initialize variables
	li $t0, INIT_LENGTH
	sw $t0, snakeLength
	li $t0, INIT_HEAD_X
	sw $t0, headX
	li $t0, INIT_HEAD_Y
	sw $t0, headY
	li $t0, DIR_RIGHT
	sw $t0, direction
		
	li $a0, INIT_HEAD_X
	li $a1, INIT_HEAD_Y
	jal pos2offset
	li $t0, SNAKE
	sw $t0, displayBuffer($v0)	# draw head pixel
	sw $v0, snakeSegment		# head offset

	li $a0, INIT_TAIL_X
	li $a1, INIT_TAIL_Y
	jal pos2offset
	li $t0, SNAKE
	sw $t0, displayBuffer($v0)	# draw tail pixel
	sw $v0, snakeSegment+4		# tail offset
	
	sw $zero, numPills
	li $t0, STATE_NORMAL
	sw $t0, state
	sw $zero, score
	
	# set seed for corresponding pseudorandom number generator using system time
	li $v0, 30
	syscall
	move $a1, $a0
	li $a0, 0	# ID = zero
	li $v0, 40
	syscall	
	
	# spawn food
	jal spawnFood

	lw $ra, ($sp)
	add $sp, $sp, 4	
	jr $ra
	
	
# void updateDisplay()
updateDisplay:
	sub $sp, $sp, 8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	lw $a0, headX
	lw $a1, headY
	lw $t0, direction
	beq $t0, DIR_RIGHT, updateDisplay.goRight
	beq $t0, DIR_DOWN, updateDisplay.goDown
	beq $t0, DIR_LEFT, updateDisplay.goLeft
	beq $t0, DIR_UP, updateDisplay.goUp
updateDisplay.goRight:
	add $a0, $a0, 1
	blt $a0, WIDTH, updateDisplay.headUpdateDone
	sub $a0, $a0, WIDTH	# wrap over if exceeds boundary
	j updateDisplay.headUpdateDone
updateDisplay.goDown:
	add $a1, $a1, 1
	blt $a1, HEIGHT, updateDisplay.headUpdateDone
	sub $a1, $a1, HEIGHT	# wrap over if exceeds boundary
	j updateDisplay.headUpdateDone
updateDisplay.goLeft:
	sub $a0, $a0, 1
	bge $a0, 0, updateDisplay.headUpdateDone
	add $a0, $a0, WIDTH	# wrap over if exceeds boundary
	j updateDisplay.headUpdateDone
updateDisplay.goUp:
	sub $a1, $a1, 1
	bge $a1, 0, updateDisplay.headUpdateDone
	add $a1, $a1, HEIGHT	# wrap over if exceeds boundary
	j updateDisplay.headUpdateDone
updateDisplay.headUpdateDone:
	sw $a0, headX
	sw $a1, headY
	jal pos2offset
	move $s0, $v0		# store the head offset because we need it later

	lw $t0, displayBuffer($s0) # what is in the next posion of head?
	beq $t0, EMPTY, updateDisplay.empty
	beq $t0, FOOD, updateDisplay.food
	beq $t0, RED_PILL, updateDisplay.redPill
	beq $t0, BLUE_PILL, updateDisplay.bluePill
	beq $t0, WALL, main.exit
	# else hit into bad thing
	li $t0, STATE_EXIT
	sw $t0, state
	j updateDisplay.ObjectDetectionDone
	
updateDisplay.empty:	# nothing
	li $t0, SNAKE
	sw $t0, displayBuffer($s0)	# draw head pixel
	
	# erase old tail in display (set color to black)
	lw $t0, snakeLength
	sub $t0, $t0, 1
	sll $t0, $t0, 2
	lw $t1, snakeSegment($t0)	# load the tail offset
	li $t2, EMPTY
	sw $t2, displayBuffer($t1)
	
	j updateDisplay.ObjectDetectionDone
	
updateDisplay.food:	#regular food
	li $t0, SNAKE
	sw $t0, displayBuffer($s0)	# draw head pixel
	lw $t0, snakeLength
	add $t0, $t0, 1
	sw $t0, snakeLength	# increase snake length
	
	jal spawnFood
	lw $t0, score
	add $t0, $t0, 1
	sw $t0, score
	
	j updateDisplay.ObjectDetectionDone
	
updateDisplay.redPill:
	li $t0, SNAKE
	sw $t0, displayBuffer($s0)	# draw head pixel
	
	# erase old tail in display (set color to black)
	lw $t0, snakeLength
	sub $t0, $t0, 1
	sll $t0, $t0, 2
	lw $t1, snakeSegment($t0)	# load the tail offset
	li $t2, EMPTY
	sw $t2, displayBuffer($t1)
	
	lw $t0, numPills
	sub $t0, $t0, 1
	sw $t0, numPills
	
	# increase game speed
	lw $t0, timeInterval
	mtc1 $t0, $f0
	cvt.s.w $f0, $f0
	l.s $f1, incSpeed
	mul.s $f0, $f0, $f1
	cvt.w.s $f0, $f0
	mfc1 $t0, $f0
	sw $t0, timeInterval
	
	j updateDisplay.ObjectDetectionDone
	
updateDisplay.bluePill:
	li $t0, SNAKE
	sw $t0, displayBuffer($s0)	# draw head pixel
	
	# erase old tail in display (set color to black)
	lw $t0, snakeLength
	sub $t0, $t0, 1
	sll $t0, $t0, 2
	lw $t1, snakeSegment($t0)	# load the tail offset
	li $t2, EMPTY
	sw $t2, displayBuffer($t1)
	
	lw $t0, numPills
	sub $t0, $t0, 1
	sw $t0, numPills
	
	# decrease game speed
	lw $t0, timeInterval
	mtc1 $t0, $f0
	cvt.s.w $f0, $f0
	l.s $f1, decSpeed
	mul.s $f0, $f0, $f1
	cvt.w.s $f0, $f0
	mfc1 $t0, $f0
	sw $t0, timeInterval
	
	j updateDisplay.ObjectDetectionDone

updateDisplay.ObjectDetectionDone:
	
	
	# update snake segments
	# for i = length-1 to 1
	#	snakeSegment[i] = snakeSegment[i-1]
	# snakeSegment[0] = new head position (stored in $s0)
	lw $t0, snakeLength	# index i
updateDisplay.snakeUpdateLoop:
	sub $t0, $t0, 1
	blt $t0, 1, updateDisplay.snakeUpdateLoopDone
	sll $t1, $t0, 2		# convert index to offset
	sub $t2, $t1, 4		# offset of previous segment
	lw $t4, snakeSegment($t2)
	sw $t4, snakeSegment($t1) # snakeSegment[i] = snakeSegment[i-1]
	j updateDisplay.snakeUpdateLoop
updateDisplay.snakeUpdateLoopDone:
	sw $s0, snakeSegment	# update head offset in snakeSegment
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	add $sp, $sp, 8
	jr $ra
	

# int pos2offset(int x, int y)
# offset = (y * WIDTH + x) * 4
# Note that each pixel takes 4 bytes!
pos2offset:
	mul $v0, $a1, WIDTH
	add $v0, $v0, $a0
	sll $v0, $v0, 2
	jr $ra


# void spawnFood()
spawnFood:
	sub $sp, $sp, 4
	sw $ra, ($sp)
	
	# spawn regular food (yellow)
spawnFood.regular:
	li $a0, WIDTH	# range: 0 <= x < WIDTH
	jal randInt
	move $t0, $v0,	# position x
	li $a0, HEIGHT	# range: 0 <= y < HEIGHT
	jal randInt
	move $t1, $v0,	# position y
	move $a0, $t0
	move $a1, $t1
	jal pos2offset
	lw $t0, displayBuffer($v0)		# get "thing" on (x, y)
	bne $t0, EMPTY, spawnFood.regular	# find another place if it is not empty
	li $t0 FOOD
	sw $t0, displayBuffer($v0)	# put the food

spawnFood.red:
	li	$a0, 5
	jal	randInt						# get random int
	move	$t1, $v0					# random int from 0 to 3
	bne	$t1, 2, spawnFood.blue				# 20% to get 2
	lw	$t0, numPills					# pill count
	beq	$t0, MAX_NUM_PILLS, spawnFood.return		# check pill count if it's max
	addi	$t0, $t0, 1					# increment pill count
	sw	$t0, numPills					# store back in numPills
	
spawnFood.red.loop:
	li	$a0, WIDTH					# range: 0 <= x < WIDTH
	jal	randInt
	move	$t0, $v0					# position x
	li	$a0, HEIGHT					# range: 0 <= y < HEIGHT
	jal	randInt
	move 	$t1, $v0					# position y
	move	$a0, $t0
	move	$a1, $t1
	jal	pos2offset
	lw	$t0, displayBuffer($v0)				# get "thing" on (x, y)
	bne	$t0, EMPTY, spawnFood.red.loop			# loop until it's empty
	li	$t0, RED_PILL
	sw	$t0, displayBuffer($v0)				# store food in positon
	
spawnFood.blue:
	li	$a0, 100
	jal	randInt
	move	$t1, $v0					# random int from 0 to 99
	bge	$t1, 15, spawnFood.return			# 15% chance to get from 0 to 14
	lw	$t0, numPills					# pill count
	beq	$t0, MAX_NUM_PILLS, spawnFood.return		# check pill count if it's max
	addi	$t0, $t0, 1					# increment pill count
	sw	$t0, numPills					# store back in numPills
	
spawnFood.blue.loop:
	li	$a0, WIDTH					# range: 0 <= x < WIDTH
	jal	randInt
	move	$t0, $v0					# position x
	li	$a0, HEIGHT					# range: 0 <= y < HEIGHT
	jal	randInt
	move 	$t1, $v0					# position y
	move	$a0, $t0					# position x in $a0
	move	$a1, $t1					# position y in $a1
	jal	pos2offset
	lw	$t0, displayBuffer($v0)				# get "thing" on (x, y)
	bne	$t0, EMPTY, spawnFood.blue.loop			# loop until it's empty
	li	$t0, BLUE_PILL
	sw	$t0, displayBuffer($v0)				# store food in positon

spawnFood.return:
	
	lw $ra, ($sp)
	add $sp, $sp, 4
	jr $ra


# void clearBuffer(char* buffer, int size)
clearBuffer:
	li $t0, 0
clearBuffer.loop:
	bge $t0, $a1, clearBuffer.return
	add $t1, $a0, $t0
	sb $zero, ($t1)
	add $t0, $t0, 1
	j clearBuffer.loop
clearBuffer.return:
	jr $ra


# int randInt(int max)
# generate an random integer n where 0 <= n < max
randInt:
	move $a1, $a0
	li $a0, 0
	li $v0, 42
	syscall
	move $v0, $a0
	jr $ra
