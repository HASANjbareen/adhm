#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define RESET   "\033[0m"
#define BOLD    "\033[1m"
#define RED     "\033[31m"
#define GREEN   "\033[32m"
#define YELLOW  "\033[33m"
#define CYAN    "\033[36m"
#define MAGENTA "\033[35m"

char board[3][3];
int scores[2];

void init_board() {
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            board[i][j] = '1' + i * 3 + j;
}

void print_board() {
    printf("\n");
    for (int i = 0; i < 3; i++) {
        printf("  ");
        for (int j = 0; j < 3; j++) {
            if (board[i][j] == 'X')
                printf(RED BOLD " X " RESET);
            else if (board[i][j] == 'O')
                printf(CYAN BOLD " O " RESET);
            else
                printf(YELLOW " %c " RESET, board[i][j]);
            if (j < 2) printf("|");
        }
        printf("\n");
        if (i < 2) printf("  ---+---+---\n");
    }
    printf("\n");
}

int check_winner(char p) {
    for (int i = 0; i < 3; i++) {
        if (board[i][0] == p && board[i][1] == p && board[i][2] == p) return 1;
        if (board[0][i] == p && board[1][i] == p && board[2][i] == p) return 1;
    }
    if (board[0][0] == p && board[1][1] == p && board[2][2] == p) return 1;
    if (board[0][2] == p && board[1][1] == p && board[2][0] == p) return 1;
    return 0;
}

int is_draw() {
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            if (board[i][j] != 'X' && board[i][j] != 'O') return 0;
    return 1;
}

int ai_minimax(char player, int is_max) {
    if (check_winner('X')) return -10;
    if (check_winner('O')) return 10;
    if (is_draw()) return 0;

    int best = is_max ? -100 : 100;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            if (board[i][j] != 'X' && board[i][j] != 'O') {
                char saved = board[i][j];
                board[i][j] = is_max ? 'O' : 'X';
                int score = ai_minimax(player, !is_max);
                board[i][j] = saved;
                best = is_max ? (score > best ? score : best)
                              : (score < best ? score : best);
            }
        }
    }
    return best;
}

void ai_move() {
    int best = -100, bi = -1, bj = -1;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            if (board[i][j] != 'X' && board[i][j] != 'O') {
                char saved = board[i][j];
                board[i][j] = 'O';
                int score = ai_minimax('O', 0);
                board[i][j] = saved;
                if (score > best) { best = score; bi = i; bj = j; }
            }
        }
    }
    board[bi][bj] = 'O';
    printf(CYAN "  AI plays position %d\n" RESET, bi * 3 + bj + 1);
}

int play_game(int vs_ai) {
    init_board();
    char players[2] = {'X', 'O'};
    int turn = 0;

    while (1) {
        print_board();
        char current = players[turn % 2];

        if (vs_ai && current == 'O') {
            ai_move();
        } else {
            if (current == 'X')
                printf(RED BOLD "  Player X" RESET ", enter position (1-9): ");
            else
                printf(CYAN BOLD "  Player O" RESET ", enter position (1-9): ");

            int pos;
            if (scanf("%d", &pos) != 1 || pos < 1 || pos > 9) {
                printf(RED "  Invalid input!\n" RESET);
                while (getchar() != '\n');
                continue;
            }
            int r = (pos - 1) / 3, c = (pos - 1) % 3;
            if (board[r][c] == 'X' || board[r][c] == 'O') {
                printf(RED "  Cell taken! Choose another.\n" RESET);
                continue;
            }
            board[r][c] = current;
        }

        if (check_winner(current)) {
            print_board();
            if (vs_ai && current == 'O')
                printf(RED BOLD "  AI wins! Better luck next time.\n" RESET);
            else if (current == 'X')
                printf(GREEN BOLD "  Player X wins!\n" RESET);
            else
                printf(CYAN BOLD "  Player O wins!\n" RESET);
            return current == 'X' ? 0 : 1;
        }

        if (is_draw()) {
            print_board();
            printf(YELLOW BOLD "  It's a draw!\n" RESET);
            return -1;
        }

        turn++;
    }
}

int main() {
    scores[0] = 0; scores[1] = 0;
    int draws = 0;

    printf(MAGENTA BOLD);
    printf("\n  ╔═══════════════════════════╗\n");
    printf("  ║      TIC-TAC-TOE          ║\n");
    printf("  ╚═══════════════════════════╝\n");
    printf(RESET);

    while (1) {
        printf(CYAN "\n  Mode: " RESET);
        printf("1) vs AI   2) 2 Players   0) Quit\n  Choice: ");
        int choice;
        if (scanf("%d", &choice) != 1) break;

        if (choice == 0) break;
        if (choice != 1 && choice != 2) {
            printf(RED "  Invalid choice.\n" RESET);
            continue;
        }

        int vs_ai = (choice == 1);
        int result = play_game(vs_ai);

        if (result == 0) scores[0]++;
        else if (result == 1) scores[1]++;
        else draws++;

        printf(YELLOW "\n  Score — X: %d | O: %d | Draws: %d\n" RESET,
               scores[0], scores[1], draws);
        printf("  Play again? (1=yes / 0=no): ");
        int again;
        if (scanf("%d", &again) != 1 || again == 0) break;
    }

    printf(MAGENTA BOLD "\n  Final Score:\n" RESET);
    printf("  X: %d | O: %d | Draws: %d\n\n", scores[0], scores[1], draws);
    return 0;
}
