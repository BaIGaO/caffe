// Copyright 2014 BVLC and contributors.

#include <algorithm>
#include <cmath>
#include <vector>

#include "caffe/layer.hpp"
#include "caffe/vision_layers.hpp"

using std::max;

namespace caffe {

template <typename Dtype>
__global__ void SigmoidForward(const int n, const Dtype* in, Dtype* out) {
  CUDA_KERNEL_LOOP(index, n) {
    out[index] = 1. / (1. + exp(-in[index]));
  }
}

template <typename Dtype>
void SigmoidLayer<Dtype>::NeuronForward_gpu(const Blob<Dtype>& bottom,
    Blob<Dtype>* top) {
  const Dtype* bottom_data = bottom.gpu_data();
  Dtype* top_data = top->mutable_gpu_data();
  const int count = bottom.count();
  // NOLINT_NEXT_LINE(whitespace/operators)
  SigmoidForward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
      count, bottom_data, top_data);
  CUDA_POST_KERNEL_CHECK;
}

template <typename Dtype>
__global__ void SigmoidBackward(const int n, const Dtype* in_diff,
    const Dtype* out_data, Dtype* out_diff) {
  CUDA_KERNEL_LOOP(index, n) {
    const Dtype sigmoid_x = out_data[index];
    out_diff[index] = in_diff[index] * sigmoid_x * (1 - sigmoid_x);
  }
}

template <typename Dtype>
void SigmoidLayer<Dtype>::NeuronBackward_gpu(const Blob<Dtype>& top,
    Blob<Dtype>* bottom) {
  const Dtype* top_data = top.gpu_data();
  const Dtype* top_diff = top.gpu_diff();
  Dtype* bottom_diff = bottom->mutable_gpu_diff();
  const int count = bottom->count();
  // NOLINT_NEXT_LINE(whitespace/operators)
  SigmoidBackward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
      count, top_diff, top_data, bottom_diff);
  CUDA_POST_KERNEL_CHECK;
}

INSTANTIATE_CLASS(SigmoidLayer);


}  // namespace caffe
