import os
import time
import datetime
import itertools
import math
import re

# رنگ‌ها
RESET = "\033[0m"
BOLD = "\033[1m"
RED = "\033[31m"
YELLOW = "\033[33m"
GREEN = "\033[32m"
CYAN = "\033[36m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"

RAINBOW = [RED, YELLOW, GREEN, CYAN, BLUE, MAGENTA]
WIDTH = 70

# کاراکترهای باکس
BOX_TL, BOX_TR, BOX_BL, BOX_BR, BOX_H, BOX_V = "╔", "╗", "╚", "╝", "═", "║"

def clear():
    os.system("cls" if os.name == "nt" else "clear")

def len_no_ansi(s: str) -> int:
    return len(re.sub(r"\x1b\[[0-9;]*m", "", s))

def box_line(text=""):
    content = f" {text}"
    pad = WIDTH - 2 - len_no_ansi(content)
    if pad < 0:
        content = content[:WIDTH-5] + "..."
        pad = 1
    return f"{BOX_V}{content}{' ' * pad}{BOX_V}"

def draw_box(lines):
    print(BOX_TL + BOX_H*(WIDTH-2) + BOX_TR)
    for ln in lines:
        print(box_line(ln))
    print(BOX_BL + BOX_H*(WIDTH-2) + BOX_BR)

def loading_animation():
    for dot in itertools.cycle([".", "..", "...", ""]):
        clear()
        print(f"{BOLD}{CYAN}Loading SEPEHR CHEAT{dot}{RESET}")
        time.sleep(0.3)
        if time.time() % 3 < 0.5:
            break

def ascii_logo():
    logo = f"""
  ███████╗███████╗██████╗ ██████╗ ██╗  ██╗██████╗ 
  ██╔════╝██╔════╝██╔══██╗██╔═══██╗██║ ██╔╝██╔══██╗
  ███████╗█████╗  ██████╔╝██║   ██║█████╔╝ ██████╔╝
  ╚════██║██╔══╝  ██╔═══╝ ██║   ██║██╔═██╗ ██╔═══╝ 
  ███████║███████╗██║     ╚██████╔╝██║  ██╗██║     
  ╚══════╝╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     
"""
    print(f"{BOLD}{MAGENTA}{logo}{RESET}")

def rainbow_title(text, step):
    colored = ""
    for i, c in enumerate(text):
        color = RAINBOW[(i + step) % len(RAINBOW)]
        colored += f"{color}{c}{RESET}"
    return colored

def gradient_fps(fps, t):
    phase = (math.sin(t) + 1) / 2
    index = int(phase * (len(RAINBOW) - 1))
    return f"{RAINBOW[index]}FPS:{RESET} {fps:.1f}"

def header(step=0):
    title = rainbow_title("⚡ SEPEHR CHEAT ⚡", step)
    bypass_text = f"bypass: {GREEN}ON{RESET}"
    return [
        title,
        bypass_text,
        "",
        "All mods are active!",
        "Options auto-refresh below..."
    ]

def main():
    states = {
        "Aim assist": True,
        "Aimbot": True,
        "Magic bullet": True,
        "Lag fix": True,
        "Ping fix": True,
    }

    loading_animation()
    prev_time = time.time()
    step = 0
    start_time = time.time()

    try:
        while True:
            current_time = time.time()
            delta = current_time - prev_time
            fps = 1 / delta if delta > 0 else 0
            prev_time = current_time
            elapsed = current_time - start_time

            clear()
            ascii_logo()
            draw_box(header(step=step))
            step += 1

            print()
            for k in states:
                print(f" - {k:<20}: {GREEN}ON{RESET}")

            now = datetime.datetime.now().strftime("%H:%M:%S")
            print(f"\n{YELLOW}System Time:{RESET} {now}   {gradient_fps(fps, elapsed)}")
            print(f"{CYAN}Press CTRL + C to stop the script.{RESET}")

            time.sleep(1.0)

    except KeyboardInterrupt:
        clear()
        print(f"{MAGENTA}Exited by user.{RESET}")

if __name__ == "__main__":
    main()
