# [Group4] Bankrutcy Prediciton

### 組員
* 鄭宇傑, 108703014
* 賴冠瑜, 108703019
* 張瀚文, 108304003
* 江宗樺, 108703029
* 田詠恩, 108703030
### 目標
95% 以上的資料中的公司都沒有破產(Bankruptcy == 0)
所以全部猜 1 就可以有超級高的 Accuracy
我們將目標設定成要盡可能增加 recall 。嘗試預測出更多可能會倒的公司去對他們做關切 或提早做應對措施，並去檢視可能面臨的問題，是這次專題的主要目標。
### Demo 
You should provide an example commend to reproduce your result
```R
Rscript code/your_script.R --input data/training --output results/performance.tsv
```
* any on-line visualization

## 檔案架構及其相關資訊

### docs
* [Google Slide for Presentation](https://docs.google.com/presentation/d/1TWPNksUenzi-DsquO6Yv7WBCVPvZE-HgyjMmvAcAH3U/edit#slide=id.g10d591fe8d9_0_169)

### data

* Source
* Input format
* Any preprocessing?
  * Handle missing data
  * Scale value

### code

* Which method do you use?
* What is a null model for comparison?
* How do your perform evaluation? ie. cross-validation, or addtional indepedent data set
使用 train, validation, test split，並且使用 SMOTE 製作額外的 traning data

### results

* Which metric do you use 
  * precision, recall, R-square
* Is your improvement significant?
* What is the challenge part of your project?

## References
https://www.kaggle.com/jerryfang5/bankrutcy-prediciton-by-r/notebook
https://www.kaggle.com/seongwonr/bankruptcy-prediction-with-smote
https://colab.research.google.com/drive/12wXAyrbX8Ji5J6CNAEIQwtDOaxy8BCIO?usp=sharing
