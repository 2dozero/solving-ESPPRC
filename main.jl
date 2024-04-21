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
    vi = first(E)
    for vj in 1:cvrp.dimension
    # if vi != vj
        Fij = Tuple{Int64, Int64, Vector{Int64}, Float64}[]
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
        old_labels_vj = labels[vj]
        labels[vj] = EFF(Fij ∪ labels[vj])

        if labels_have_changed(old_labels_vj, labels[vj])
            push!(E, vj)
        end

        # if all(labels[vj][1][3] .== 1)
        #     @show labels[vj]
        #     # Send the vehicle back to node 1
        #     Q, s_i, v, C = labels[vj][1]
        #     @show (euclidean_distance(cvrp, vj, 1) - alpha * pi_i[1, 1])
        #     C += (euclidean_distance(cvrp, vj, 1) - alpha * pi_i[1, 1])
        #     labels[vj][1] = (Q, s_i, v, C)
        # end

    delete!(E, vi)
    end
end

@show labels