import supervisely_lib as sly
import tensorflow as tf
import numpy as np

# PyPlot only for rendering images inside Jupyter.
% matplotlib
inline
import matplotlib.pyplot as plt
import os

# Jupyter notebooks hosted on Supervisely can get their user's
# credentials from the environment varibales.
# If you are running the notebook outside of Supervisely, plug
# the server address and your API token here.
# You can find your API token in the account settings:
# -> click your name in the top-right corner
# -> select "account settings"
# -> select "API token" tab on top.
address = os.environ['SERVER_ADDRESS']
token = os.environ['API_TOKEN']

print("Server address: ", address)
print("Your API token: ", token)

# Initialize the API access object.
api = sly.Api(address, token)

# In Supervisely, a user can belong to multiple teams.
# Everyone has a default team with just their user in it.
# We will work in the context of that default team.
team = api.team.get_list()[0]

# Query for all the workspaces in the selected team
workspaces = api.workspace.get_list(team.id)
print("Team {!r} contains {} workspaces:".format(team.name, len(workspaces)))
for workspace in workspaces:
    print("{:<5}{:<15s}".format(workspace.id, workspace.name))

print(workspaces[0])

workspace_name = 'tutorial_workspace'

# Just in case there is already a workspace with this name,
# we can ask the web instance for a new unique name to use.
if api.workspace.exists(team.id, workspace_name):
    workspace_name = api.workspace.get_free_name(team.id, workspace_name)

# Create the workspace and print out its metadata.
workspace = api.workspace.create(team.id, workspace_name, ' workspace description')
print(workspace)

workspace_by_name = api.workspace.get_info_by_name(team.id, workspace_name)
print(workspace_by_name)
print()

workspace_by_id = api.workspace.get_info_by_id(workspace.id)
print(workspace_by_id)
# update workspace name, description, or both
new_name = 'my_super_workspace'
new_description = 'super workspace description'
if api.workspace.exists(team.id, new_name):
    new_name = api.workspace.get_free_name(team.id, new_name)

print("Before update: {}\n".format(workspace))

workspace = api.workspace.update(workspace.id, new_name, new_description)

print("After  update: {}".format(workspace))

# 'lemons_annotated' is one of our out of the box demo projects, so
# we will make a copy with the appropriate name.
project_name = 'lemons_annotated_clone'
if api.project.exists(workspace.id, project_name):
    project_name = api.project.get_free_name(workspace.id, project_name)

task_id = api.project.clone_from_explore('Supervisely/Demo/lemons_annotated', workspace.id, project_name)

# The clone call returns immediately, so the code does not
# have to block on waiting for the task to complete.
# Since we do not have much to do in the meantime, just wait for the task.
api.task.wait(task_id, api.task.Status.FINISHED)

# Now that the task has finished we can query for the project metadata.
project = api.project.get_info_by_name(workspace.id, project_name)
print("Project {!r} has been sucessfully cloned from explore: ".format(project.name))
print(project)

projects = api.project.get_list(workspace.id)
print("Workspace {!r} contains {} projects:".format(workspace.name, len(projects)))
for project in projects:
    print("{:<5}{:<15s}".format(project.id, project.name))

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

# Download the serialized JSON annotation for the image.
ann_info = api.annotation.download(image.id)
# Parse the annotation using the Supervisely Python SDK
# and instantiate convenience wrappers for the objects in the annotation.
ann = sly.Annotation.from_json(ann_info.annotation, meta)

# Render the object labels on top of the original image.
img_with_ann = img.copy()
ann.draw(img_with_ann)
imgplot = plt.imshow(img_with_ann)

# Set the destination model name within our workspace
model_name = 'yolo_coco'

# Grab a unique name in case the one we chose initially is busy.
if api.model.exists(workspace.id, model_name):
    model_name = api.model.get_free_name(workspace.id, model_name)

# Request the model to be copied from our public repository.
# This kicks off an asynchronous task.
task_id = api.model.clone_from_explore('Supervisely/Model Zoo/YOLO v3 (COCO)', workspace.id, model_name)

# Wait for the copying to complete.
api.task.wait(task_id, api.task.Status.FINISHED)

# Query the metadata for the copied model.
model = api.model.get_info_by_name(workspace.id, model_name)
print("Model {!r} has been sucessfully cloned from explore: ".format(model.name))

api.model.download_to_tar(workspace.id, model.name, './model.tar')