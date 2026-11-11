#!/bin/bash
#SBATCH --job-name=validate
#SBATCH --account=project_2020507
#SBATCH --partition=small
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=32G
#SBATCH -o ./logs/%x_%j.out
#SBATCH -e ./logs/%x_%j.err

###############################################################################
# Check that JSONL files are well formed, without modifying them. This is the
# SLURM launcher for validate_jsonl.py: it loads the python-data module, which
# provides Python and the zstd command, and passes every argument through.
#
#   sbatch validate_jsonl.sh [options] PATH [PATH ...]
#
# Options and behaviour are described in validate_jsonl.py; see them with
#   bash validate_jsonl.sh -h
#
# Notes
#   • Submit from the Roihu-data-helpers directory. SLURM runs a copy of this
#     script from its spool directory, so validate_jsonl.py is looked up in
#     the submission directory.
###############################################################################

set -euo pipefail

# Inside a job, $0 is SLURM's copy of this script; outside one, it is this file.
HELPERS_DIR=${SLURM_SUBMIT_DIR:-$(dirname -- "$(realpath -- "$0")")}
VALIDATOR="$HELPERS_DIR/validate_jsonl.py"
if [[ ! -f "$VALIDATOR" ]]; then
  echo "Error: $VALIDATOR not found; submit from the Roihu-data-helpers directory" >&2
  exit 1
fi

# zstd is not on Roihu's default PATH; the python-data module provides it.
module purge
module load python-data

exec python3 "$VALIDATOR" "$@"
