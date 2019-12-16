##Learning Kernel Similarity Embedding for Dynamic Texture Synthesis


![](https://github.com/shiming-chen/Similariy-DT/blob/master/core-idea.jpg)
[[Project]](https://shiming-chen.github.io/Similarity-page/Similarity.html) [[Paper]](https://arxiv.org/abs/1911.04254)

## Overview 
- [Installation](##installation)
- [Train](##generation)
- [Baseline](##baseline)
- [References](##references)
- [Citation](##citation)
- [Contact](##contact)




## Installation
1. Clone this repo.

```
git clone https://github.com/shiming-chen/Similariy-DT.git
cd Similarity-DT
```



## Generation

#### Generating gray DTs

Run `Similarity_gray('DT_name','save_name')`

#### Generating RGB DTs

Run `Similarity_RGB('DT_name','save_name')`

#### Transfering Trained Model for Generation

Run `Similarity_RGB_transfer('train_DT_name','test_DT_name','save_name')`

## Baseline

#### Non-Neural-Network-Based Method
We provide the codes for the compared non-neural-network-based methods, i.e., LDS, SLADS, Kernel-DT, FFT-LDS, HOSVD, KPCR.

#### Neural-Network-Based Method
The projects page of [TwoStream](https://ryersonvisionlab.github.io/two-stream-projpage/), [STGCN](http://www.stat.ucla.edu/~jxie/STGConvNet/STGConvNet.html), and [DG](http://www.stat.ucla.edu/~jxie/DynamicGenerator/DynamicGenerator.html) as follow:

1. TwoStream: [https://ryersonvisionlab.github.io/two-stream-projpage/](https://ryersonvisionlab.github.io/two-stream-projpage/)
2. STGCN: [http://www.stat.ucla.edu/~jxie/STGConvNet/STGConvNet.html](http://www.stat.ucla.edu/~jxie/STGConvNet/STGConvNet.html)
3. DG:  [http://www.stat.ucla.edu/~jxie/DynamicGenerator/DynamicGenerator.html](http://www.stat.ucla.edu/~jxie/DynamicGenerator/DynamicGenerator.html)



## Citation
If this work is helpful for you, please cite my paper.

```
@article{Chen2019SimilarityDTKS,
  title={Learning Kernel Similarity Embedding for Dynamic Texture Synthesis},
  author={Shiming Chen and Peng Zhang and Xinge You and Qinmu Peng and Xin Liu, Zehong Cao, Dacheng Tao},
  journal={ArXiv},
  year={2019},
  volume={abs/1911.04254}
}
```

## Contact
If you run into any problems with these codes, please submit a bug report on the Github site of the project. For another inquries please contact with me: gchenshiming@gmail.com or shimingchen@hust.edu.cn.





