# Industrial Virtualized Network Template
Simulated Industrial Network Template for OT Security Competitions or Projects

## Setting up your own OT Network
- git clone the repo and then remove the `.git` directory with `rm -rf .git`
- Then do the process of starting the new repo:
-  `git init`
-  `git add .`
-  `git commit -m "New Repo"`

## Running or Testing the OT Network
```bash
chmod +x testing.sh
./testing.sh
```

## For documentation 
- Go to the `docs` folder 

## Diagram of OT Network
![Image](https://github.com/user-attachments/assets/af0c0f3e-7e12-4d81-a50c-400759c1e04f)


## Guide for how to make your own OT Network using this template
- Make your own simulated python components and add their configurations to the `docker-compose.yml` in the folder where your simulated components are



## Credit
- Couldn't have made this without the creation of Virtue Pot by Nikhil Karakuchi (https://github.com/0xnkc/virtuepot/), you can find his Master's Thesis paper on VirtuePot here: https://thesis.unipd.it/handle/20.500.12608/71043
- As well as the diagrams throughout the Industrial Cybersecurity (Second Edition) book by Pascal Ackerman & Packt
