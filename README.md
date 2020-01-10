## Kernel Similarity Embedding for DT Synthesis <!--[[Project]](https://shiming-chen.github.io/Similarity-page/Similarity.html) [[Paper]](https://arxiv.org/abs/1911.04254)-->


<!--![](https://github.com/shiming-chen/Similariy-DT/blob/master/core-idea1.jpg)-->



## Overview 
- [Installation](##installation)
- [Generation (Running on Windows)](##Generation (Running on Windows))
- [Baseline](##baseline)
- [Citation](##citation)
- [Contact](##contact)




## Installation
1. Clone this repo.

```
git clone https://github.com/shiming-chen/Similariy-DT.git
cd Similarity-DT
```



## Generation (Running on Windows)

#### 1. Generating gray DTs

Run `Similarity_gray('DT_name','save_name')`

#### 2. Generating RGB DTs

Run `Similarity_RGB('DT_name','save_name')`

#### 3. Transfering Trained Model for Generation

Run `Similarity_RGB_transfer('train_DT_name','test_DT_name','save_name')`

## Baseline

#### 1. Non-Neural-Network-Based Methods
We provide the codes for the compared non-neural-network-based methods, i.e., [LDS](), [SLDS](), [Kernel-DT](), [FFT-LDS](), [HOSVD](), [KPCR]().

#### 2. Neural-Network-Based Methods
The project pages of [TwoStream](https://ryersonvisionlab.github.io/two-stream-projpage/), [STGCN](http://www.stat.ucla.edu/~jxie/STGConvNet/STGConvNet.html), and [DG](http://www.stat.ucla.edu/~jxie/DynamicGenerator/DynamicGenerator.html) are presented as follow:

1. TwoStream: [https://ryersonvisionlab.github.io/two-stream-projpage/](https://ryersonvisionlab.github.io/two-stream-projpage/)
2. STGCN: [http://www.stat.ucla.edu/~jxie/STGConvNet/STGConvNet.html](http://www.stat.ucla.edu/~jxie/STGConvNet/STGConvNet.html)
3. DG:  [http://www.stat.ucla.edu/~jxie/DynamicGenerator/DynamicGenerator.html](http://www.stat.ucla.edu/~jxie/DynamicGenerator/DynamicGenerator.html)



## Citation
If this work is helpful for you, please cite my paper.

```
@article{Chen2019SimilarityDTKS,
  title={Similarity-DT: Kernel Similarity Embedding for Dynamic Texture Synthesis},
  author={Shiming Chen and Peng Zhang and Xinge You and Qinmu Peng and Xin Liu, Zehong Cao, Dacheng Tao},
  journal={ArXiv},
  year={2019},
  volume={abs/1911.04254}
}
```

## Contact
If you run into any problems with these codes, please submit a bug report on the Github site of the project. For another inquries please contact with me: gchenshiming@gmail.com or shimingchen@hust.edu.cn.





