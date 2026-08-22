#include <kimodo/kimodo.hpp>
#include <array>
#include <cstdio>
int main(int argc,char**argv){if(argc!=2)return 2;auto m=kimodo::model::load(argv[1]);if(!m){std::fprintf(stderr,"%s\n",m.error().c_str());return 1;}std::array<float,kimodo::embedding_width> e{};auto r=(*m)->generate_embedding(e,2,1,42,2.f,2.f);if(!r){std::fprintf(stderr,"%s\n",r.error().c_str());return 1;}if(r->frames!=2||r->joints!=22||r->root_positions.size()!=6||r->local_rotations_xyzw.size()!=176)return 1;return 0;}
