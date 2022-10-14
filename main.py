import pygame
import sys

WIDTH = 600
HEIGHT = 600
DISPLAY = pygame.display.set_mode((WIDTH, HEIGHT))

class Player(pygame.sprite.Sprite):
    def __init__(self):
        super(Player, self).__init__()
        self.width = 100
        self.height = 25
        self.surf = pygame.Surface((self.width, self.height))
        self.surf.fill((255,255,255))
        self.rect = self.surf.get_rect()
        self.rect.bottom = HEIGHT - HEIGHT/8
        self.rect.left = WIDTH/2 - self.width/2
        self.vel = 0

    def update(self, pressedKeys):
        '''Update the position of the player'''
        if pressedKeys[pygame.K_a]:
            self.vel = -1
        elif pressedKeys[pygame.K_d]:
            self.vel = 1
        else:
            self.vel = 0

        self.rect.move_ip(self.vel, 0)

        if self.rect.left < 0:
            self.rect.left = 0
        if self.rect.right > WIDTH:
            self.rect.right = WIDTH

class Ball(pygame.sprite.Sprite):
    def __init__(self):
        super(Ball, self).__init__()
        self.surf = pygame.Surface((10, 10))
        self.surf.fill((100, 100, 100))
        pygame.draw.circle(self.surf, (0, 0, 200), (5, 5), 5)
        self.rect = self.surf.get_rect()
        self.rect.bottom = HEIGHT/8
        self.rect.left = WIDTH/2 - 5
        self.vel = 1

    def update(self):
        self.rect.bottom += self.vel
        if self.rect.top <= 0:
            self.vel = -self.vel

def main():
    # Initialize pygame sub-modules
    pygame.init()

    # Initialize our player and ball
    player = Player()
    ball = Ball()

    # Main loop
    while True:
        # Look at every event in the pygame event queue
        for event in pygame.event.get():
            # If the user closes the window, exit the program
            if event.type == pygame.QUIT:
                sys.exit()

            # If the user hits the esc key or q, exit the program
            if event.type == pygame.KEYDOWN:
                if event.key in [pygame.KEYDOWN, pygame.K_q]:
                    sys.exit()

        # Get pressed keys
        pressedKeys = pygame.key.get_pressed()

        # Update player and ball positions
        player.update(pressedKeys)
        ball.update()

        if ball.rect.colliderect(player.rect):
            ball.vel = -ball.vel

        # Reset the screen
        DISPLAY.fill((100, 100, 100))

        # Draw the current player and ball positions
        DISPLAY.blit(player.surf, player.rect)
        DISPLAY.blit(ball.surf, ball.rect)

        # Update the screen
        pygame.display.update()

# Call main function
main()
