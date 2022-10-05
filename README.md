# Snake (MIPS Assembly)
To launch game, go to MARS, “Tools” →“Keyboard and Display MMIO Simulator”, and click “Connect to MIPS” to have your “keyboard”. For the display, you need to go to the menu “Tools” →“Bitmap Display”, change both unit height and width to “8”, and click “Connect to MIPS”. The tool will display a buffer (displayBuffer in the code) in the data segment (by interpreting the buffer as an array of RGB colors), and this is your “monitor”. Now, assemble and run the code.

To play the game, use 'wasd' to move, "q" to quit, "r" to restart, "p" to pause or resume.

There will always be one regular pill, eat it to grow.
Red pills will spawn at 20% chance and will increase the game speed by 20%.
Blue pills will spawn at 15% chance and will decrease the game speed by 15%.
