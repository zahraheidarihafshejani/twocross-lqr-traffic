from pathlib import Path
import argparse
import random

# python generate_routes.py --cycles 15

def generate_routefile(num_cycles=15):
    cycle_length = 90
    end_time = num_cycles * cycle_length
    rng = random.Random(42)

    route_file = Path(__file__).resolve().parent / "twocross.rou.xml"
    route_file.parent.mkdir(parents=True, exist_ok=True)

    count = 0
    burst_count = 0

    with route_file.open("w", encoding="utf-8") as routes:
        print("""<?xml version="1.0" encoding="UTF-8"?>
<routes>
    <vType id="typeWE" accel="3.0" decel="4.5"
           sigma="0.2" length="5" minGap="2.5"
           maxSpeed="16.67" guiShape="passenger"/>
    <vType id="typeNS" accel="3.0" decel="4.5"
           sigma="0.2" length="7" minGap="3"
           maxSpeed="25" guiShape="bus"/>

    <route id="left_to_right" edges="1i 2o 5i 6o"/>
    <route id="right_to_left" edges="6i 5o 2i 1o"/>
    <route id="bottom_to_left" edges="8i 5o 2i 1o"/>
    <route id="bottom_to_right" edges="3i 2o 5i 6o"/>
""", file=routes)

        for t in range(end_time):
            # در ۱۵ سیکل: یک موج در 540..899
            # در ۵۰ سیکل: موج‌های تکراری با فاصلهٔ ۱۸۰۰ ثانیه
            burst = 540 <= (t % 1800) < 900

            demands = (
                ("left_to_right",  "typeWE", 1 / 10),
                ("right_to_left",  "typeWE", 1 / 11),
                ("bottom_to_right", "typeNS", 0.55 if burst else 1 / 30),
                ("bottom_to_left",  "typeNS", 1 / 20),
            )

            for route_id, vehicle_type, probability in demands:
                if rng.random() < probability:
                    print(
                        f'    <vehicle id="v{count}" type="{vehicle_type}" '
                        f'route="{route_id}" depart="{t}" '
                        f'departLane="best"/>',
                        file=routes,
                    )
                    count += 1
                    if burst and route_id == "bottom_to_right":
                        burst_count += 1

        print("</routes>", file=routes)  # فقط یک بار

    print(f"Route file: {route_file}")
    print(f"Simulation demand horizon: {end_time} s")
    print(f"Generated vehicles: {count}")
    print(f"Vehicles generated on 3i during bursts: {burst_count}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--cycles", type=int, choices=[15, 50], default=15)
    args = parser.parse_args()
    generate_routefile(args.cycles)
