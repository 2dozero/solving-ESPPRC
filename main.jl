include("function.jl")
using CSV
using DataFrames
using CVRPLIB
cvrp, vrp_file, sol_file = readCVRPLIB("P-n16-k8")
# cvrp, vrp_file, sol_file = readCVRPLIB("A-n32-k5")
pi_i = CSV.read("dual_var_P-n16-k8.csv", DataFrame, header = false)
# pi_i = CSV.read("dual_var_A-n32-k5.csv", DataFrame, header = false)

p = 1
alpha = 1.3
labels = Dict{Int, Array{Tuple{Int, Int, Vector{Int}, Float64}, 1}}()
for node in 1:cvrp.dimension
    labels[node] = []
end
labels[p] = [(0, 0, [0 for _ in 1:cvrp.dimension], 0.0)]
E = Set([p])

while !isempty(E)
    # vi = pop!(E)
    # @show E
    vi = first(E)
    for vj in 1:cvrp.dimension
    # if vi != vj
        Fij = Vector{Tuple{Int64, Int64, Vector{Int64}, Float64}}()
        for label in labels[vi]
            if label[3][vj] == 0
                extended_label = extend(label, vi, vj, cvrp, alpha, pi_i)
                # @show extended_label
                if extended_label == nothing
                    continue
                end
                push!(Fij, extended_label)
            end
        end
        # for (Q, s_i, v, C) in Fij
        #     # @show v
        #     if all(vi -> vi == 1, v)
        #         distance = euclidean_distance(cvrp, vi, 1)
        #         # @show C
        #         C = C + distance - alpha * pi_i[1, 1]
        #         # @show C
        #         push!(Fij, (Q, s_i, v, C))
        #     end
        # end
        new_Fij = Vector{Tuple{Int64, Int64, Vector{Int64}, Float64}}()
        for (Q, s_i, v, C) in Fij
            if all(vi -> vi == 1, v)
                distance = euclidean_distance(cvrp, vi, 1)
                println("..")
                @show C
                C = C + distance - alpha * pi_i[1, 1]
                push!(new_Fij, (Q, s_i, v, C))
                @show C
            else
                push!(new_Fij, (Q, s_i, v, C))  # If v is not all ones, keep the original tuple
            end
        end
        Fij = new_Fij

        old_labels_vj = labels[vj]
        # labels[vj] = EFF(Fij ∪ labels[vj])
        labels[vj] = EFF(Fij, labels[vj])

        if labels_have_changed(old_labels_vj, labels[vj])
            push!(E, vj)
        end

    delete!(E, vi)
    end
end

@show labels

min_cost = Inf
for label_list in values(labels)
    for label in label_list
        cost = label[4]  # Assuming the cost is the 4th element in the label tuple
        if cost < min_cost
            min_cost = cost
        end
    end
end

println("Minimum cost: ", min_cost)