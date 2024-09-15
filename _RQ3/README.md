# RQ2 Experiment

## Average Jaccard Similarity Coefficient

Workdir: `./overlap/jaccard_similarity`

`./overlap/jaccard_similarity/RQ3_j2-j6.ipynb` outputs J2 to J6.

## UpSet diagram

Workdir: `./overlap/upset_data`

`./overlap/upset_data/RQ3_upset_diagram.ipynb` outputs the UpSet diagrams for five high-risk vulnerabilities.

### REN

![REN](./overlap/upset_data/RQ3_upset_graph_SWC-107.png)

Tool combination recommendation: {Vandal}

### USI

![USI](./overlap/upset_data/RQ3_upset_graph_SWC-106.png)


Tool combination recommendation: {Ethainter, Mythril, Vandal, Verismart}

### TXO

![TXO](./overlap/upset_data/RQ3_upset_graph_SWC-115.png)

Tool combination recommendation: {Solhint}

### UEW

![UEW](./overlap/upset_data/RQ3_upset_graph_SWC-105.png)

Tool combination recommendation: {Semgrep, Mythril, Ethainter, Vandal, Slither, VeriSmart}

### IOU

![IOU](./overlap/upset_data/RQ3_upset_graph_SWC-101.png)

Tool combination recommendation: {Verismart, Madmax, Semgrep}