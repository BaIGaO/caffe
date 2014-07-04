// Copyright 2014 BVLC and contributors.
// TanH neuron activation function layer.
// Adapted from ReLU layer code written by Yangqing Jia

#include <algorithm>
#include <vector>

#include "caffe/layer.hpp"
#include "caffe/vision_layers.hpp"

namespace caffe {

template <typename Dtype>
__global__ void TanHForward(const int n, const Dtype* in, Dtype* out) {
  CUDA_KERNEL_LOOP(index, n) {
    Dtype exp2x = exp(2 * in[index]);
    out[index] = (exp2x - Dtype(1)) / (exp2x + Dtype(1));
  }
}

template <typename Dtype>
void TanHLayer<Dtype>::NeuronForward_gpu(const Blob<Dtype>& bottom,
    Blob<Dtype>* top) {
  const Dtype* bottom_data = bottom.gpu_data();
  Dtype* top_data = top->mutable_gpu_data();
  const int count = bottom.count();
  // NOLINT_NEXT_LINE(whitespace/operators)
  TanHForward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
      count, bottom_data, top_data);
  CUDA_POST_KERNEL_CHECK;
}

template <typename Dtype>
__global__ void TanHBackward(const int n, const Dtype* in_diff,
    const Dtype* out_data, Dtype* out_diff) {
  CUDA_KERNEL_LOOP(index, n) {
    Dtype tanhx = out_data[index];
    out_diff[index] = in_diff[index] * (1 - tanhx * tanhx);
  }
}

template <typename Dtype>
void TanHLayer<Dtype>::NeuronBackward_gpu(const Blob<Dtype>& top,
    Blob<Dtype>* bottom) {
  const Dtype* top_data = top.gpu_data();
  const Dtype* top_diff = top.gpu_diff();
  Dtype* bottom_diff = bottom->mutable_gpu_diff();
  const int count = bottom->count();
  // NOLINT_NEXT_LINE(whitespace/operators)
  TanHBackward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
      count, top_diff, top_data, bottom_diff);
  CUDA_POST_KERNEL_CHECK;
}

INSTANTIATE_CLASS(TanHLayer);


}  // namespace caffe
