from datetime import datetime
from pathlib import Path

stdout_root = (
    Path(__file__).parent.resolve().relative_to(Path.cwd())
    / f"{datetime.now().strftime('%Y-%m-%d-%H-%M')}"
)

commands = []
for num_nodes in [1, 2]:
    for gradient_clipping in [1.0, 100.0]:
        jobid = f"{num_nodes}-nodes-clip-at-{gradient_clipping}"
        commands.append(
            (
                "sbatch "
                f"-N {num_nodes} "
                f"-o {stdout_root}/out/{jobid}.out "
                f"-e {stdout_root}/out/{jobid}.err "
                f"-p debug -t 00:30:00 "
                "./installation/docker-arm64-cuda/CSCS-Clariden-setup/ee628-submit-scripts/unattended-ds-zero1.sh "
                f"--gradient_clipping={gradient_clipping} "
                "-m ee628.play_with_deepspeed "
            )
        )

# Write th submit commands to a new directory where this batch of experiments will be managed)
# Path from the project root
submit_dir = Path.cwd() / str(stdout_root)
submit_dir.mkdir(parents=True, exist_ok=True)
submit_file = submit_dir / "submit.sh"
print(f"Writing {len(commands)} commands to {submit_file}")
with open(submit_file, "w") as f:
    for command in commands:
        f.write(command + "\n")
