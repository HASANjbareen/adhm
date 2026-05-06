#!/usr/bin/env python3
import curses
import random
import time

def main(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(3, curses.COLOR_YELLOW, curses.COLOR_BLACK)
    curses.init_pair(4, curses.COLOR_CYAN, curses.COLOR_BLACK)

    sh, sw = stdscr.getmaxyx()
    win = curses.newwin(sh, sw, 0, 0)
    win.keypad(True)
    win.timeout(120)

    snake = [(sh // 2, sw // 4 + i) for i in range(4)]
    direction = curses.KEY_RIGHT
    food = (sh // 2, sw // 2)
    score = 0
    speed = 120

    def place_food():
        while True:
            y = random.randint(1, sh - 2)
            x = random.randint(1, sw - 2)
            if (y, x) not in snake:
                return (y, x)

    while True:
        win.clear()

        # Draw border
        win.attron(curses.color_pair(4))
        win.border()
        win.attroff(curses.color_pair(4))

        # Draw score
        win.attron(curses.color_pair(3))
        win.addstr(0, 2, f" Score: {score} | WASD or Arrow Keys | Q to Quit ")
        win.attroff(curses.color_pair(3))

        # Draw food
        win.attron(curses.color_pair(2))
        win.addch(food[0], food[1], '@')
        win.attroff(curses.color_pair(2))

        # Draw snake
        for i, (y, x) in enumerate(snake):
            win.attron(curses.color_pair(1))
            win.addch(y, x, '#' if i == 0 else 'o')
            win.attroff(curses.color_pair(1))

        win.refresh()

        key = win.getch()

        if key in (ord('q'), ord('Q')):
            break

        if key in (curses.KEY_UP, ord('w'), ord('W')) and direction != curses.KEY_DOWN:
            direction = curses.KEY_UP
        elif key in (curses.KEY_DOWN, ord('s'), ord('S')) and direction != curses.KEY_UP:
            direction = curses.KEY_DOWN
        elif key in (curses.KEY_LEFT, ord('a'), ord('A')) and direction != curses.KEY_RIGHT:
            direction = curses.KEY_LEFT
        elif key in (curses.KEY_RIGHT, ord('d'), ord('D')) and direction != curses.KEY_LEFT:
            direction = curses.KEY_RIGHT

        head = snake[0]
        if direction == curses.KEY_UP:
            new_head = (head[0] - 1, head[1])
        elif direction == curses.KEY_DOWN:
            new_head = (head[0] + 1, head[1])
        elif direction == curses.KEY_LEFT:
            new_head = (head[0], head[1] - 1)
        else:
            new_head = (head[0], head[1] + 1)

        # Wall collision
        if (new_head[0] <= 0 or new_head[0] >= sh - 1 or
                new_head[1] <= 0 or new_head[1] >= sw - 1):
            break

        # Self collision
        if new_head in snake:
            break

        snake.insert(0, new_head)

        if new_head == food:
            score += 10
            food = place_food()
            speed = max(50, speed - 2)
            win.timeout(speed)
        else:
            snake.pop()

    # Game over screen
    win.clear()
    win.attron(curses.color_pair(2))
    msg = f"GAME OVER! Final Score: {score}"
    win.addstr(sh // 2, (sw - len(msg)) // 2, msg)
    win.attroff(curses.color_pair(2))
    win.attron(curses.color_pair(3))
    win.addstr(sh // 2 + 1, (sw - 22) // 2, "Press any key to exit...")
    win.attroff(curses.color_pair(3))
    win.refresh()
    win.timeout(-1)
    win.getch()


if __name__ == "__main__":
    curses.wrapper(main)
