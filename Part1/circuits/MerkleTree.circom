pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var leaves_length = 2**n;
    var hash_counts = 2*leaves_length - 1;
    component allHashes[hash_counts];

    if (n == 0) {
        root <== leaves[0];
    } else {
        // input given leaves to allHashes component
        var index = 1;
        for (var i = 0; i < leaves_length; i++) {
            allHashes[i] = leaves[i];
            index++;
        }

        component poseidon[hash_counts-leaves_length];

        // compute hash & input to allHashes component
        for (var i = n-1; i >= 0; i--) {  // i: n-1 ~ 0
            for (var j = 0; j < 2**i; j++) {
                poseidon[index-leaves_length] = Poseidon(2);
                poseidon[index-leaves_length] <== allHashes[j*2];
                poseidon[index-leaves_length] <== allHashes[j**2 + 1];
                allHashes[index] = poseidon[index-leaves_length].out;
                index++;
            }
        }

        // compute root hash
        poseidon[index-leaves_length] = Poseidon(2);
        poseidon[index-leaves_length].inputs[0] <== allHashes[index - 2];
        poseidon[index-leaves_length].inputs[1] <== allHashes[index - 1];
        allHashes[index] = poseidon[index-leaves_length].out;

        root <== allHashes[index];
    }
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon[n];

    var hash = leaf;

    for (var i = 0; i < n; i++) {
        poseidon[i] = Poseidon(2);
        poseidon[i].inputs[0] <== (path_elements[i] - hash)*path_index[i] + hash;
        poseidon[i].inputs[1] <== (hash - path_elements[i])*path_index[i] + path_elements[i];
        hash = poseidon[i].out;
    }

    root <== hash;
}