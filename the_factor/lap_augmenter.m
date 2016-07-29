function[A] = lap_augmenter(A,num_nodes,type)

prob = 10/size(A,1);
switch type
    case 1
        nodes = randsample(size(A,1),num_nodes,0);
        for i = 1:num_nodes
            cur_node = nodes(i);
            A([1:(cur_node-1) (cur_node+1):end],cur_node) = A([1:(cur_node-1) (cur_node+1):end],cur_node)+ binornd(ones(size(A,1)-1,1),prob);
            A(cur_node, [1:(cur_node-1) (cur_node+1):end]) = A([1:(cur_node-1) (cur_node+1):end],cur_node);
        end
    case 2
        
        A_add = zeros(size(A,1)+num_nodes,num_nodes);
        for i = 1:num_nodes
            connections = binornd(ones(size(A,1)+num_nodes-1,1),prob);
            if i < num_nodes
                A_add([1:(size(A,1)+i-1) (size(A,1)+i+1):end],i) = connections;
            else
                A_add(1:1:(size(A,1)+i-1),i) = connections;
            end
        end
end