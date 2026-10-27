# Large raw artifacts (release assets)

These files are excluded from git history and are attached to the release of this repository.
Download the archives from the Releases page and unpack them into this directory.

| File | Size | Needed for |
|---|---|---|
| raw_inference_logs.tar.gz | ~66 MB | raw OpenCompass per-question outputs (2912 files), Fig. 4 heatmap |
| aime2024_all_data.tar.gz | ~53 MB | packaged AIME 2024 run data, Fig. 2 AIME panel |
| aime2024_7b_pass1_n64_raw_20260528.tar.gz | ~427 MB | raw 7B AIME runs for Fig. 4 |
| aime2024_8b_pass1_n64_raw_20260528.tar.gz | ~497 MB | raw 8B AIME runs for Fig. 4 |

Unpack instructions:

    tar -xzf raw_inference_logs.tar.gz
    tar -xzf aime2024_7b_pass1_n64_raw_20260528.tar.gz
    tar -xzf aime2024_8b_pass1_n64_raw_20260528.tar.gz

The summary tables actually used in the manuscript are in ../tables/ and do not require these archives.
