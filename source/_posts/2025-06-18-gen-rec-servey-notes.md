---   
layout: post   
title: "GenRec综述论文笔记"   
date: 2025-06-18 09:51   
comments: true   
categories: RecSys   
tags: GenRec LLM4Rec 多模态   
---   

论文链接：[https://arxiv.org/abs/2409.15173](https://arxiv.org/abs/2409.15173)

# book structure

<center>{% img /images/2025/IMAG2025061801.webp %}</center>

<!--more-->

Advantages of recommender systems with generative models

<center>{% img /images/2025/IMAG2025061802.webp %}</center>

Outline of key techniques and publications in LLM-driven RSs

<center>{% img /images/2025/IMAG2025061803.webp %}</center>

# Chap4-LLM Rec

## 4.3 Encoder-only LLM Rec

**encoder-only LLMs** can be used in two main architectures: as dense retrievers (c.f. Sec 4.3.1) or as cross-encoders (c.f. Sec 4.3.2).

<center>{% img /images/2025/IMAG2025061804.webp %}</center>

Autoregressive LLM inputs are called prompts, which are sequences of tokens expressing a task such as top-k recommendation, rating prediction, or explanation generation.

<center>{% img /images/2025/IMAG2025061805.webp %}</center>

## 4.5 Retrieval Augmented Rec

<center>{% img /images/2025/IMAG2025061806.webp %}</center>

## 4.6 LLMs Representation Generation

<center>{% img /images/2025/IMAG2025061807.webp %}</center>

## 4.7 Conversational Rec

<center>{% img /images/2025/IMAG2025061808.webp %}</center>

# Chap5-Multi-modal GMs for Rec

## 5.1 Introduction

Why?——item cold start problem, user request understanding, complex recsys scenes(virtual try-on, conversational shopping assistans)

Challenges——alignment，latent space learning

## 5.2 Contrastive Multimodal Rec

CLIP

<center>{% img /images/2025/IMAG2025061809.webp %}</center>

Align BEfore Fuse (ALBEF) 

<center>{% img /images/2025/IMAG2025061810.webp %}</center>

## 5.3 Generative Multimodal Rec

GAN

<center>{% img /images/2025/IMAG2025061811.webp %}</center>

VAE

<center>{% img /images/2025/IMAG2025061812.webp %}</center>

Diffusion

<center>{% img /images/2025/IMAG2025061813.webp %}</center>

## 5.4 Applications of Multimodal Rec

- E-commerce

- product visualization-virtual try on

- Marketing-create personalized ad images and videos

- Streaming services-Long and short-form video,music,audiobooks,podcasts,radio

- Travel
