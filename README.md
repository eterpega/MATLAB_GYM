# Overview <br />

The program is designed for MATLAB hack day. It tries to bridge Matlab to OpenAI Gym platform and potentially Simulink. <br />

## Software requirement: <br />

Game Platform: require python3, [gym](https://github.com/openai/gym), pygame, [gym-ple](https://github.com/lusob/gym-ple) and [osim-rl](https://github.com/stanfordnmbl/osim-rl) <br />
- The flappy bird in gym-ple has a bug that incorrectly implement the hit condition. To use the correct version, go to "PyGame-Learning-Environment" folder in this repo, and type "pip install -e ."
- To run the human NMS system from NIPS Learn to run, make sure that you have installed and activated the conda environment as suggested in osim-rl.
- Control: developed in Matlab 2017a and linux environment <br />

## To run the code: <br />

Firstly setup server by typing "python gym_http_server.py", then run the "example.m" to test simple/rl controller. Feel free to develop your own controller from AbstractController. <br />

## Design Idea: <br />
- The http-api design refers to [gym-http-api](https://github.com/openai/gym-http-api) <br />
- For the flappy bird game, .mat file is used to transmit images to avoid overhead in jsonify

## To do: <br />
- [ ] Implement DDPG algorithm to address continuous control problem in RL framework <br />
- [ ] Use system identification to identify system model and develop optimal controller
