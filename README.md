# TankBattleSinglePlayerVsAi
Tank Battle with Single Player vs one or multiple Ai agents. Or Ai vs Ai agents in Go Dot using Godot RL

# How to open project locally on my machine for training
  !Important: I assume the godot_rl_agents and virtual machine is installed. Visit https://www.youtube.com/watch?v=f8arMv_rtUU for reference on how to do this
  1) Go inside the virtual machine 

   Inside the C:\Users\emili\OneDrive\Documents\Python programs\RL_test\rl\Scripts open Command Prompt (not windowspowershell)

   Execute the command: activate 

   Now you are inside the (rl), notice the (rl) in the beginning of the path name
   (rl) C:\Users\emili\OneDrive\Documents\Python programs\RL_test\rl\Scripts>

  2) cd ../.. and go to the (rl) C:\Users\emili\OneDrive\Documents\Python programs\RL_test directory
     Execute the stable_baselines3_example.py script, just type stable_baselines3_example.py

  3) The server is waiting for you to connect
  4) Open the project in Godot
  5) Make sure the Sync node is located in your starting scene
  6) Press Run game and the training starts

# How to export and use the onnx model of your model

  You need to run the game in C# in order to use the onnx model, you can export it normally from your normal training where you used GDScript
  
  1) export the onnx file by starting the stable baselines with command below
     stable_baselines3_example.py --onnx_export_path=model.onnx --timesteps=100_000
  2) Install mono version of godot if not already installed
  3) Install dot net sdk if not already installed dotnet-sdk-8.0.303-win-x64.exe
  4) What i did now in order not destroy the original godot project, was to copy the whole project in another folder and delete git files so these changes are
     not tracked, open the project in godot mono and create a new dummy script which uses C# and delete it immediately. If you run the game it will try
     to build a .net project and fail
  5) Add the onnx dependency
     While in the (rl) go to the project folder and install the onnx dependency with the command
       dotnet add package Microsoft.ML.OnnxRuntime --version 1.15.1
     The latest version on 20/7/2024 is 1.18.1, but I installed 1.15.1 which the version the tutorial uses, I also use the rl_agents of the tutorial
     which is also an older version.
  6) move the onnx file which was generated in the C:\Users\emili\OneDrive\Documents\Python programs\RL_test directory
  7) Make sure to open project in godot mono
  8) In the sync node choose the onnx file path and set control mode to Onnx Inference
  9) Press play and play against your model
  
