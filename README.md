# Elixir Bash Script Generator App

**Send Bash commands in unsorted order via curl and execute them directly in sorted order**

## Requirements
- Erlang/OTP 22 [erts-10.6.2]
- Elixir (1.9.4)

## Installation

- mix deps.get
- iex -S mix

## Testing

- mix test

## Examples
-  Generate and Execude Bash Commands

    `curl -v -H 'Content-Type: application/json' "http://localhost:4000/generate" -d @print_text_task_1.json | bash`
    
- Get Sorted Bash Commands

    `POST http://localhost:4000/sort`
    
    `Content-Type: application/json`
    
    Body example:
    
        {
          "tasks":[
              {
                  "name":"task-1",
                  "command":"touch file2"
              },
              {
                  "name":"task-2",
                  "command":"ls -lah file2",
                  "requires":[
                      "task-3",
                      "task-5"
                  ]
              },
              {
                  "name":"task-3",
                  "command":"echo 'Hello World!' > file2",
                  "requires":[
                      "task-1"
                  ]
              },
              {
                  "name":"task-4",
                  "command":"pwd",
                  "requires":[
                      "task-2",
                      "task-3",
                      "task-5"
                  ]
              },
              {
                  "name":"task-5",
                  "command":"cat file2",
                  "requires":[
                      "task-1",
                      "task-3"
                  ]
              }
          ]
        }
        
    Response example:
    
        [
            {
                "name": "task-1",
                "command": "touch file1"
            },
            {
                "name": "task-3",
                "command": "echo 'Hello World!' > file1"
            },
            {
                "name": "task-5",
                "command": "cat file1"
            },
            {
                "name": "task-2",
                "command": "rm /tmp/file1"
            },
            {
                "name": "task-4",
                "command": "pwd"
            }
        ]
        
 *Ready for use JSONs are placed in `bash_tasks` folder
        
## Development hints

### Task-Queue Sorting Algorithm - Think up steps

Acc structure example:

     %{
        "sorted" => [], 
        "executed" => [], 
        "queued" => %{"task-50" => [%{"name" => "task-5"}, %{"name" => "task-2"}]}
      }

    Execute me:

    1. if I have no deps add me to the sorted and then to executed
    
        check in queued if someone waits for me (queued[my_name])
        
            if no one waits for me, go to the next task
            
            if someone waits for me, get its queue [t3,t2,t1] reversed in a new variable and remove the queue from queued, then foreach task in its own queue [t1,t2,t3] execute -> T.1
		
    2. if has deps foreach dep do a check if the dep is in executed
    
        if all of my deps are found in the executed, then remove my deps (the “requires” key) and execute me -> T.1
        
        if some of my deps is not found inside executed, create a not executed list [t50, t87]
        
            foreach dep in this not executed list check if dep_name (t50) exists in my list having key “in_queue”
            
                if all deps exists in “in_queue” list return acc
                
                if some deps are not in “in_queue”, foreach of these deps check if dep_name (t50) key exist in the queued
                
                    if exists insert me to the end of the deb_name (t50) => [1,2,3,me] and go to the next task
                    
                    if not exists put me into queued (deb_name (t50) => [me]) and go to the next task
                    
                    finally add dep_name (t50) into my “in_queue” key (create “in_queue” if not present)
                    
            after foreach ends go to the next task
