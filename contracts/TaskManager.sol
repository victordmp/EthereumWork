pragma solidity 0.5.4;
pragma experimental ABIEncoderV2;

contract TaskManager {
    /*  
        Representa o número de tarefas, conforme for sendo criadas 
        novas tarefas esse núemro vai sendo incrementado.
    */
    uint public nTasks; 
    
    /* 
        Em que está a tarefa
    */
    enum TaskPhase {ToDo, InProgress, Done, Blocked, Review, Postponed, Canceled}

    /* 
        Tipo da tarefa
    */
    enum TypeTask {Personal, Family, Home, Work, Review, Student}
    
    /* 
        Estrutura da tarefa:
            criador/dono,
            nome da tarefa,
            fase da tarefa,
            tipo de dprioridade
    */
    struct TaskStruct {
        address owner;
        string name;
        TaskPhase phase;
        TypeTask ttype;
        /* 
            A prioridade varia de 1-5. Sendo 1 prioridade muito alta e 5 menos importante.
        */
        uint priority; 
    }
    /* 
        Arrey de tarefas
    */
    TaskStruct[] private tasks;
    /* 
        Arrey de tarefas por prioridade
    */
    TaskStruct[] private taskByPriority;

    /* 
        Estrutura de chave valor. Vale lembrar que ele 
        adiciona uma tarefa ele já vincula o id da tarefa 
        dentro desse array chamado de myTasks.
    */
    mapping (address => uint[]) private myTasks;

    /* 
        Gera um evento toda vez que criamos uma nova tarefa.
    */
    event TaskAdded(address owner, string name, TaskPhase phase, uint priority);
    
    /*
        O método modofoer, verifíca e válida se o usuário é de 
        fato o dono da tarefa. Para poder fazer alguma requisição.
    */
    modifier onlyOwner (uint _taskIndex) {
         if  (tasks[_taskIndex].owner == msg.sender) {
           _;
        }
    }
    
    /* 
        Método contrutor. Neste caso ele incializa com 0 nTasks.
        E também cria 3 tarefas.
    */
    constructor() public {
        nTasks = 0;
        addTask ("Create Task Manager", TaskPhase.Done, TypeTask.Work, 1);
        addTask ("Create Your first task", TaskPhase.ToDo, TypeTask.Personal, 2);
        addTask ("Clean your house", TaskPhase.ToDo, TypeTask.Home, 5);
        addTask ("Watch new spider man movie", TaskPhase.InProgress, TypeTask.Family, 3);
        addTask ("watch new episode of onpiece", TaskPhase.ToDo, TypeTask.Personal, 5);
    }    

    /* 
        Função que pega as tasks
    */
    function getTask(uint _taskIndex) public view
        returns (address owner, string memory name, TaskPhase phase, TypeTask ttype, uint priority) {
        require ((tasks.length > _taskIndex), "Tasks not found");
        owner = tasks[_taskIndex].owner;
        name = tasks[_taskIndex].name;
        phase = tasks[_taskIndex].phase;
        ttype = tasks[_taskIndex].ttype;
        priority = tasks[_taskIndex].priority;
    }
    
    /* 
        Função que lista todas as tarefas de um usuario(dono)
    */
    function listMyTasks() public view returns (uint[] memory) {
        return myTasks[msg.sender];
    }

    /* 
        Função responsavel por atualizar o array de tarefas de acordo com uma prioridade
    */
    function updateArrayTaskByPriority(uint _priority) private {
        /* 
            Limpa o array de tarefas por prioridade
        */
        delete taskByPriority;

        uint[] memory myTasksAll = myTasks[msg.sender];
        
        for (uint index = 0; index < myTasksAll.length; index++) {    
            if (tasks[myTasksAll[index]].priority == _priority) {
                TaskStruct memory taskAux = TaskStruct ({
                    owner: msg.sender,
                    name: tasks[myTasksAll[index]].name,
                    phase: tasks[myTasksAll[index]].phase, 
                    ttype: tasks[myTasksAll[index]].ttype,
                    priority: tasks[myTasksAll[index]].priority
                });
                taskByPriority.push(taskAux);
            }
        }
    }
    
    /* 
        Função que lista todas as tarefas de um usuario(dono) 
        de uma determinada prioridade.
    */
    function listMyTasksByPriority(uint _priority) public returns (TaskStruct[] memory) {
        /*
            Lança um exeção se a prioridade passada for 
            menor que 0 ou maior que 5
        */
        require ((_priority >= 1 && _priority <=5), "Priority must be between 1 and 5");
        /* 
            Chama a função que limpa o array de tarefas por prioridade, 
            e depois insere apartir de uma nova prioridade
        */
        updateArrayTaskByPriority(_priority);
        /*
            Lança um exeção se a o array de prioridades for 
            menor que ou igual a 0
        */
        require ((taskByPriority.length > 0), "No tasks with this priority found");
        
        return taskByPriority;
    }
    
    /* 
        Função que cria uma nova tarefa
    */
    function addTask(string memory _name, TaskPhase _phase, TypeTask _type, uint _priority) public returns (uint index) {
        require ((_priority >= 1 && _priority <=5), "priority must be between 1 and 5");
        TaskStruct memory taskAux = TaskStruct ({
            owner: msg.sender,
            name: _name,
            phase: _phase, 
            ttype: _type,
            priority: _priority
        });
        index = tasks.push (taskAux) - 1;
        nTasks ++;
        myTasks[msg.sender].push(index);
        emit TaskAdded (msg.sender, _name, _phase, _priority);
    }
    
    /* 
        Função que atualiza a fase do projeto
    */
    function updatePhase(uint _taskIndex, TaskPhase _phase) public onlyOwner(_taskIndex) {
        tasks[_taskIndex].phase = _phase;
    }

    /* 
        Função que atualiza a o nome do projeto
    */
    function updateName(uint _taskIndex, string _name) public onlyOwner(_taskIndex) {
        tasks[_taskIndex].name = _name;
    }
}