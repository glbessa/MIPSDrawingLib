# Shapes:
# 0 -> nothing
# 1 -> square
# 2 -> rectangle
# 3 -> circle

.data
	# Arguments
	args: .space 20
	
	# Display size
	width:  .word 128
	height: .word 64
	
	# Colors
	black:  .word 0x000000
	white:  .word 0xffffff
	yellow: .word 0xffc200
	
	# Objects
	# 0 -> x
	# 1 -> y
	# 2 -> xLength
	# 3 -> yLength
	# 4 -> color
	# 5 -> shape
	# MinSpace = 20
	objects: .space 60 # 3 objects
	 
.text
	j main

	main:
		# Initialization ------------
		# display address
		lui $s0, 0x1000 # display
		
		# display width and height
		lw $s1, width
		lw $s2, height
		
		# colors
		lw $s3, yellow
		
		# objects
		la $s4, objects
		
		jal clearFrame
		# --------------------------
		# Ops ----------------------

		li $a0, 0
		la $a1, args
		li $t0, 15
		li $t1, 9
		li $t2, 20
		li $t3, 10
		lw $t4, yellow
		sw $t0, 0($a1)
		sw $t1, 4($a1)
		sw $t2, 8($a1)
		sw $t3, 12($a1)
		sw $t4, 16($a1)
		jal CreateObject

		li $a0, 0
		jal DrawObject
	
		li $a0, 1
		la $a1, args
		li $t0, 20
		li $t1, 30
		li $t2, 20
		li $t3, 10
		lw $t4, white
		sw $t0, 0($a1)
		sw $t1, 4($a1)
		sw $t2, 8($a1)
		sw $t3, 12($a1)
		sw $t4, 16($a1)
		jal CreateObject

		jal DrawObject

		li $a0, 0
		li $a1, 60
		li $a2, 50
		jal MoveObject

		li $a0, 15
		li $a1, 9
		move $a2, $s3
		la $a3, args
		li $t0, 20
		sw $t0, 0($a3)
		li $t1, 10
		sw $t1, 4($a3)	
		#jal drawRectangle
		
		#jal clearFrame

		li $a0, 5
		li $a1, 5
		move $a2, $s3
		la $a3, args
		li $t0, 20
		sw $t0, 0($a3)
		li $t1, 4
		sw $t1, 4($a3)
		#jal drawRectangle
		
		#jal clearFrame
		
		li $a0, 25
		li $a1, 25
		move $a2, $s3
		la $a3, args
		li $t0, 20
		sw $t0, 0($a3)
		li $t1, 20
		sw $t1, 4($a3)
		#jal drawRectangle				
						
		j end
   
   	# Draw a pixel on display
	# a0 -> x
	# a1 -> y   
	# a2 -> color
	drawPixel:
		# Save context
    		move $v0, $t0
		jal Push
    		move $v0, $t1
		jal Push
  
 		# X
    		sll $t1, $a0, 2 # convert to memory positions
          
          	# Y
		mult $a1, $s1 # move to y
		mflo $t0
		sll $t0, $t0, 2 # times 4, convert to memory positions
		add $t0, $t0, $s0 # apply to display
    
    		# Pixel address
		add $t0, $t0, $t1 # move to x and apply to display
		
		# Apply color
		sw $a2, ($t0)
		
		# Restore context
		jal Pop
		move $t1, $v0
		jal Pop
		move $t0, $v0
				
		jr $ra
    
    	# Draw rectangle
    	# a0 -> x
    	# a1 -> y
    	# a2 -> color
    	# a3 -> args
    	#
    	# args:
    	# 0 -> xMax
    	# 1 -> yMax
    	drawRectangle:
    		move $v0, $ra
		jal Push
		
		move $t3, $a1
		lw $t4, 0($a3)
		lw $t5, 4($a3)
		
		add $t6, $a0, $t4 # max x
		add $t7, $a1, $t5 # max y
		
		xLoopRectangle:
			beq $a0, $t6, endLoopRectangle
			
			yLoopRectangle:
				beq  $a1, $t7, xNextRectangle
				
				jal  drawPixel
				
				addi $a1, $a1, 1
				j    yLoopRectangle
				
			xNextRectangle:
			
			move $a1, $t3
			
			addi $a0, $a0, 1
			j    xLoopRectangle
			
		endLoopRectangle:
		
		jal Pop
		jr $v0
    
	# Draw square
	# a0 -> x
	# a1 -> y
	# a2 -> color
	# a3 -> size
	drawSquare:
		move $v0, $ra
		jal Push
		
		move $t3, $a1
		
		add $t6, $a0, $a3 # max x
		add $t7, $a1, $a3 # max y
		
		xLoopSquare:
			beq $a0, $t6, endLoopSquare
			
			yLoopSquare:
				beq  $a1, $t7, xNextSquare
				
				jal  drawPixel
				
				addi $a1, $a1, 1
				j    yLoopSquare
				
			xNextSquare:
			
			move $a1, $t3
			
			addi $a0, $a0, 1
			j    xLoopSquare
			
		endLoopSquare:
		
		jal Pop
		jr $v0

	# Create an object at memory
	# a0 -> object index
	# a1 -> args address
	CreateObject:
		move $v0, $ra
		jal Push
		
		# get object base addr
		li $t0, 24
		mult $a0, $t0
		mflo $t0
		add $t0, $t0, $s4
		
		lw $t1, 0($a1)
		lw $t2, 4($a1)
		lw $t3, 8($a1)
		lw $t4, 12($a1)
		lw $t5, 16($a1)
		
		sw $t1, 0($t0)
		sw $t2, 4($t0)
		sw $t3, 8($t0)
		sw $t4, 12($t0)
		sw $t5, 16($t0)
	
		jal Pop
		jr $v0
	
	# Draw object
	# a0 -> object index
	DrawObject:
		move $v0, $ra
		jal Push
		
		move $v0, $a0
		jal Push
		
		li $t0, 24
		mult $a0, $t0
		mflo $t0
		add $t0, $t0, $s4
		
		lw $a0, 0($t0)
		lw $a1, 4($t0)
		lw $t1, 8($t0)
		lw $t2, 12($t0)
		lw $a2, 16($t0)
		
		la $a3, args
		sw $t1, 0($a3)
		sw $t2, 4($a3)
		
		jal drawRectangle
		
		jal Pop
		move $a0, $v0
		
		jal Pop
		jr $v0
	
	# Move object
	# a0 -> object index
	# a1 -> new x
	# a2 -> new y
	MoveObject:
		move $v0, $ra
		jal Push
		
		move $v0, $a0
		jal Push		
		move $v0 $a1
		jal Push
		move $v0, $a2
		jal Push
		
		jal ClearObject
		
		jal Pop
		move $a2, $v0
		jal Pop
		move $a1, $v0
		jal Pop
		move $a0, $v0	
			
		li $t0, 24
		mult $a0, $t0
		mflo $t0
		add $t0, $t0, $s4
		
		sw $a1, 0($t0)
		sw $a2, 4($t0)
		
		jal DrawObject
	
		jal Pop
		jr $v0
	
	
	# Animate an object
	# a0 -> object index
	# a1 -> new x
	# a2 -> new y
	# a3 -> speed
	AnimateObject:
		move $v0, $ra
		jal Push
		
		# save context
		move $v0, $a0
		jal Push		
		move $v0 $a1
		jal Push
		move $v0 $a2
		jal Push
		move $v0 $a3
		jal Push		
		
		# load object base addr
		li $t0, 24
		mult $a0, $t0
		mflo $t0
		add $t0, $t0, $s4
		
		# get initial x and y
		lw $t1, 0($t0)
		lw $t2, 4($t0)
		
		
		negativeXSpeed:
		
		
		negativeYSpeed
		
		
		xLoopAnimate:
			beq $a0, $t6, endLoopAnimate
			
			yLoopAnimate:
				beq  $a1, $t7, xNextAnimate
				
				jal  MoveObject
				
				add $a1, $a1, $a1
				j    yLoopAnimate
				
			xNexAnimate:
			
			move $a1, $t3
			
			addi $a0, $a0, 1
			j    xLoopSquare
			
		endLoopSquare:
		
		# Restore context
		jal Pop
		move $a3, $v0
		jal Pop
		move $a2, $v0
		jal Pop
		move $a1, $v0
		jal Pop
		move $a0, $v0
		
		jal Pop
		jr $v0
	
	# Clear object on display
	# a0 -> object index
	ClearObject:
		move $v0, $ra
		jal Push
		
		li $t0, 24
		mult $a0, $t0
		mflo $t0
		add $t0, $t0, $s4
		
		lw $a2, black
		la $a3, args
		lw $a0, 0($t0)
		lw $a1, 4($t0)
		lw $t1, 8($t0)
		lw $t2, 12($t0)
		
		sw $t1, 0($a3)
		sw $t2, 4($a3)
		
		jal drawRectangle
		
		jal Pop
		jr $v0

	# Clear frame
	clearFrame:
		move $v0, $ra
		jal Push
		
		move $a0, $0
		move $a1, $0
		lw   $a2, black
		la   $a3, args
		sw $s1, 0($a3)
		sw $s2, 4($a3)
		
		jal drawRectangle
		
		jal Pop
		jr $v0

	# push to stack
	# args:
	# 	v0 -> address
	Push:
		addiu $sp, $sp, -4
		sw    $v0, ($sp)
		jr $ra

	# pop of stack
	# return:
	# 	v0 -> address
	Pop:
		lw    $v0, ($sp)
		addiu $sp, $sp, 4
		jr $ra

	end:
		li $v0, 10
		syscall