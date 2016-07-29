function[E,gen_pop] = tree_graph_maker(gens,kids)

total_nodes = 1;
gen_pop = zeros(gens,1);
for cur_gen = 1:gens
    if cur_gen == 1;
        gen_pop(cur_gen) = kids;
    else
        gen_pop(cur_gen) = gen_pop(cur_gen-1)*kids;
    end
    total_nodes = total_nodes+gen_pop(cur_gen);
end

parents = 1;
end_node=1;
E = zeros(total_nodes);

for cur_gen = 1:gens
    new_parents = [];
    for cur_parent = 1:length(parents)
        E(parents(cur_parent),(end_node+1):(end_node+kids)) = 1;
        new_parents = [new_parents (end_node+1):(end_node+kids)];
        end_node = max(new_parents);
    end
    parents = new_parents;
    end_node = max(parents);
end

E = E+E';