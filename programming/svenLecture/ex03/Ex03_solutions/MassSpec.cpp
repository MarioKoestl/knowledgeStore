#include<iostream>
#include<vector>
#include<algorithm>


/*
 * This program solves the coin exchange problem based on the dynamic
 * programming algorithm presented in Boecker and Liptka 2005
 * "Efficient Mass Decompostion. It not only returns an optimal
 * solution but also all possible sollutions which is importand for
 * instance in mass spectrometry experiments, where peaks need to be
 * mapped to sample molecules whose mass they could be represent.
 */


/* 
 * fill the boolean DP matrix 
 */
void populate_matrix(std::vector< std::vector <int> >& matrix, std::vector<int> aa_vec, std::vector<int> prot_vec) {
  for (int x=0;x<aa_vec.size();x++) {
    for (int y=0;y<prot_vec.size();y++) {

      if (prot_vec[y]%aa_vec[x]) matrix[x][y]=0;
      else if (prot_vec[y]%aa_vec[x]==0) matrix[x][y]=1;

      if (x>0) {
	if (prot_vec[y]<aa_vec[x]) matrix[x][y]=matrix[x-1][y];
	else if (prot_vec[y]>=aa_vec[x]){
	  if (matrix[x][y]==0 && matrix[x-1][y] || matrix[x][y-aa_vec[x]]) matrix[x][y]=1;
	}
      }
    }
  }
}		

/*
 * own implementation of a selection sort
 */
std::vector<int> sort(std::vector<int> pot_solution) {
  std::vector<int> sort_vec = pot_solution;
  for (int a=0;a<sort_vec.size();a++) {
    int maxpos=a;
    for (int b=a+1;b<sort_vec.size();b++) {
      if (sort_vec[b] > sort_vec[maxpos]) maxpos=b;
    }
    if (maxpos > a) {
      int temp=0;
      temp = sort_vec[a];
      sort_vec[a] = sort_vec[maxpos];
      sort_vec[maxpos] = temp;			
    }
  }
  return sort_vec;
}

/*
 * generate a valid solution
 */
void build_solution(const std::vector< std::vector<int> > & matrix, int index, int prot_mass, std::vector<int>& aa_vec, std::vector<int>& pot_solution, std::vector< std::vector<int> >& solutions) {
  for (int i=aa_vec.size()-1;i>=0;i--) {
    if (matrix[i][index] && prot_mass-aa_vec[i]>=0) {
      pot_solution.push_back(aa_vec[i]);
      if (prot_mass-aa_vec[i]>0) {
	build_solution(matrix, index-aa_vec[i], prot_mass-aa_vec[i], aa_vec, pot_solution, solutions);
	pot_solution.pop_back();	
      }
      else if (prot_mass-aa_vec[i]==0) {
	std::vector<int> sort_vec;
	sort_vec = sort(pot_solution);				
	solutions.push_back(sort_vec);
	pot_solution.pop_back();
      }
    }

  }
}

int main() {

  int prot_mass=0, set=20;

  std::cout << "Enter mass. ";
  std::cin >> prot_mass;

  // vector for the amino acid mass + sorting

  std::vector<int> aa_vec(set);
  int eing = 1, i=0;

  std::cout << "Enter mass of amino acids (quit with 0)." << std::endl;
  for(; i<set && eing!=0; i++) {
    std::cin >> eing;
    aa_vec[i] = eing;
  }
  //std::cout << i << std::endl; // print i
  std::sort(aa_vec.begin(), aa_vec.begin()+(i-1));
  aa_vec.resize(i-1);
  //std::cout << aa_vec.size();

  std::cout << std::endl << "Vector of AA:" << std::endl;
  for (int d=0;d<aa_vec.size();d++) {std::cout << aa_vec[d] << " ";} // print vector of aa
  std::cout << std::endl;

  // vector for protein mass

  std::vector<int> prot_vec(prot_mass);
  for (int i=0;i<prot_mass;i++) {
    prot_vec[i]=(i+1);
  }

  //for (int d=0;d<prot_vec.size();d++) {std::cout << prot_vec[d] << " ";} // print vector of mass
  //std::cout << std::endl;

  // int matrix of protein masses % aa masses

  std::vector< std::vector<int> > matrix;

  matrix.resize(i-1);
  for(int e=0;e<(i-1);e++) matrix[e].resize(prot_mass);

  populate_matrix(matrix, aa_vec, prot_vec);

  /*// print matrix
    std::cout << std::endl << "Matrix:" << std::endl;
    for (int d=0;d<(i-1);d++) { 
    for (int e=0;e<prot_mass;e++) {std::cout << matrix[d][e] << " ";}
    std::cout << std::endl;
    }*/

  std::cout << std::endl << "Solution(s):" << std::endl;

  std::vector<int> pot_solution;
  std::vector< std::vector<int> > solutions;

  for (int y=aa_vec.size()-1;y>=0;y--) {
    int z=prot_mass-1;
    if (matrix[y][z]) {
      pot_solution.push_back(aa_vec[y]);
      build_solution(matrix, (prot_mass-1)-aa_vec[y], prot_mass-aa_vec[y], aa_vec, pot_solution, solutions);
      pot_solution.pop_back();
    }
	
  }

  std::sort (solutions.begin(), solutions.end());
  std::vector< std::vector<int> >::iterator it;
  it = std::unique (solutions.begin(), solutions.end());
  solutions.resize(std::distance(solutions.begin(),it));

  for (unsigned int i=0;i<solutions.size();i++) {
    for (unsigned int j=0;j<solutions[i].size();j++) {
      std::cout << solutions[i][j] << " ";
    }
    std::cout << std::endl;
  }

  return 0;
}
