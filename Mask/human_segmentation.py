import supervisely_lib as sly
import tensorflow as tf
import numpy as np

# PyPlot only for rendering images inside Jupyter.
% matplotlib
inline
import matplotlib.pyplot as plt
import os

# Get project info by name
project = api.project.get_info_by_name(workspace.id, project_name)
if project is None:
    print("Workspace {!r} not found".format(project_name))
else:
    print(project)
print()

# Get project info by id.
project = api.project.get_info_by_id(project.id)
if project is None:
    print("Project with id={!r} not found".format(some_project_id))
else:
    print(project)

# get number of datasets and images in project
datasets_count = api.project.get_datasets_count(project.id)
images_count = api.project.get_images_count(project.id)
print("Project {!r} contains:\n {} datasets \n {} images\n".format(project.name, datasets_count, images_count))

meta_json = api.project.get_meta(project.id)
meta = sly.ProjectMeta.from_json(meta_json)
print(meta)

datasets = api.dataset.get_list(project.id)
print("Project {!r} contains {} datasets:".format(project.name, len(datasets)))
for dataset in datasets:
    print("Id: {:<5} Name: {:<15s} images count: {:<5}".format(dataset.id, dataset.name, dataset.images_count))

dataset = datasets[0]
images = api.image.get_list(dataset.id)
print("Dataset {!r} contains {} images:".format(dataset.name, len(images)))
for image in images:
    print("Id: {:<5} Name: {:<15s} labels count: {:<5} size(bytes): {:<10} width: {:<5} height: {:<5}"
          .format(image.id, image.name, image.labels_count, image.size, image.width, image.height))

# Download and display the image.
image = images[0]
img = api.image.download_np(image.id)
print("Image Shape: {}".format(img.shape))
imgplot = plt.imshow(img)

imgplot = plt.imshow(img)
image = images[0]
img = api.image.download_np(image.id)

for image in images:
    print("Id: {:<5} Name: {:<15s} labels count: {:<5} size(bytes): {:<10} width: {:<5} height: {:<5}"
          .format(image.id, image.name, image.labels_count, image.size, image.width, image.height))
