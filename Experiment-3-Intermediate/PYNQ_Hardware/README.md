# PYNQ board execution files

Upload this complete folder and open `Project3_ECG_Demo.ipynb` inside it.
The notebook's BIT, HWH, reference model and input ECG CSV are all beside it,
matching its existing relative paths. Run the notebook on a physical PYNQ-Z2.
`ecg_filter_test.ipynb` is the earlier short diagnostic notebook.

`Supporting_Data_and_Results/` contains the original captured JSON and CSV
outputs; the original graph PNGs are in `../Images/`. The demo notebook retains
its real saved outputs. Rerunning it writes fresh results in this folder.
The XSA contains the same BIT as the supplied overlay and is included as the
hardware handoff; it is not required by the PYNQ `Overlay` call.
