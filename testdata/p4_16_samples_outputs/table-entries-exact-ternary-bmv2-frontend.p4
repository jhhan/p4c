#include <core.p4>
#include <v1model.p4>

header hdr {
    bit<8>  e;
    bit<16> t;
    bit<8>  l;
    bit<8>  r;
    bit<1>  v;
}

struct Header_t {
    hdr h;
}

struct Meta_t {
}

parser p(packet_in b, out Header_t h, inout Meta_t m, inout standard_metadata_t sm) {
    state start {
        b.extract<hdr>(h.h);
        transition accept;
    }
}

control vrfy(in Header_t h, inout Meta_t m) {
    apply {
    }
}

control update(inout Header_t h, inout Meta_t m) {
    apply {
    }
}

control egress(inout Header_t h, inout Meta_t m, inout standard_metadata_t sm) {
    apply {
    }
}

control deparser(packet_out b, in Header_t h) {
    apply {
        b.emit<hdr>(h.h);
    }
}

control ingress(inout Header_t h, inout Meta_t m, inout standard_metadata_t standard_meta) {
    @name("a") action a_0() {
        standard_meta.egress_spec = 9w0;
    }
    @name("a_with_control_params") action a_with_control_params_0(bit<9> x) {
        standard_meta.egress_spec = x;
    }
    @name("t_exact_ternary") table t_exact_ternary_0 {
        key = {
            h.h.e: exact @name("h.h.e") ;
            h.h.t: ternary @name("h.h.t") ;
        }
        actions = {
            a_0();
            a_with_control_params_0();
        }
        default_action = a_0();
        entries = {
            (8w0x1, 16w0x1111 &&& 16w0xf) : a_with_control_params_0(9w1);
            (8w0x2, 16w0x1181) : a_with_control_params_0(9w2);
            (8w0x3, 16w0x1111 &&& 16w0xf000) : a_with_control_params_0(9w3);
            (8w0x4, default) : a_with_control_params_0(9w4);
        }

    }
    apply {
        t_exact_ternary_0.apply();
    }
}

V1Switch<Header_t, Meta_t>(p(), vrfy(), ingress(), egress(), update(), deparser()) main;
