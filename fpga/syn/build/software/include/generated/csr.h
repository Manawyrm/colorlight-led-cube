//--------------------------------------------------------------------------------
// Auto-generated by LiteX (cb85a8ca) on 2023-01-19 21:40:00
//--------------------------------------------------------------------------------
#include <generated/soc.h>
#ifndef __GENERATED_CSR_H
#define __GENERATED_CSR_H
#include <stdint.h>
#include <system.h>
#ifndef CSR_ACCESSORS_DEFINED
#include <hw/common.h>
#endif /* ! CSR_ACCESSORS_DEFINED */
#ifndef CSR_BASE
#define CSR_BASE 0x0L
#endif

/* ctrl */
#define CSR_CTRL_BASE (CSR_BASE + 0x0L)
#define CSR_CTRL_RESET_ADDR (CSR_BASE + 0x0L)
#define CSR_CTRL_RESET_SIZE 1
static inline uint32_t ctrl_reset_read(void) {
	return csr_read_simple((CSR_BASE + 0x0L));
}
static inline void ctrl_reset_write(uint32_t v) {
	csr_write_simple(v, (CSR_BASE + 0x0L));
}
#define CSR_CTRL_RESET_SOC_RST_OFFSET 0
#define CSR_CTRL_RESET_SOC_RST_SIZE 1
static inline uint32_t ctrl_reset_soc_rst_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 0) & mask );
}
static inline uint32_t ctrl_reset_soc_rst_read(void) {
	uint32_t word = ctrl_reset_read();
	return ctrl_reset_soc_rst_extract(word);
}
static inline uint32_t ctrl_reset_soc_rst_replace(uint32_t oldword, uint32_t plain_value) {
	uint32_t mask = 0x1;
	return (oldword & (~(mask << 0))) | (mask & plain_value)<< 0 ;
}
static inline void ctrl_reset_soc_rst_write(uint32_t plain_value) {
	uint32_t oldword = ctrl_reset_read();
	uint32_t newword = ctrl_reset_soc_rst_replace(oldword, plain_value);
	ctrl_reset_write(newword);
}
#define CSR_CTRL_RESET_CPU_RST_OFFSET 1
#define CSR_CTRL_RESET_CPU_RST_SIZE 1
static inline uint32_t ctrl_reset_cpu_rst_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 1) & mask );
}
static inline uint32_t ctrl_reset_cpu_rst_read(void) {
	uint32_t word = ctrl_reset_read();
	return ctrl_reset_cpu_rst_extract(word);
}
static inline uint32_t ctrl_reset_cpu_rst_replace(uint32_t oldword, uint32_t plain_value) {
	uint32_t mask = 0x1;
	return (oldword & (~(mask << 1))) | (mask & plain_value)<< 1 ;
}
static inline void ctrl_reset_cpu_rst_write(uint32_t plain_value) {
	uint32_t oldword = ctrl_reset_read();
	uint32_t newword = ctrl_reset_cpu_rst_replace(oldword, plain_value);
	ctrl_reset_write(newword);
}
#define CSR_CTRL_SCRATCH_ADDR (CSR_BASE + 0x4L)
#define CSR_CTRL_SCRATCH_SIZE 1
static inline uint32_t ctrl_scratch_read(void) {
	return csr_read_simple((CSR_BASE + 0x4L));
}
static inline void ctrl_scratch_write(uint32_t v) {
	csr_write_simple(v, (CSR_BASE + 0x4L));
}
#define CSR_CTRL_BUS_ERRORS_ADDR (CSR_BASE + 0x8L)
#define CSR_CTRL_BUS_ERRORS_SIZE 1
static inline uint32_t ctrl_bus_errors_read(void) {
	return csr_read_simple((CSR_BASE + 0x8L));
}

/* ethphy */
#define CSR_ETHPHY_BASE (CSR_BASE + 0x800L)
#define CSR_ETHPHY_CRG_RESET_ADDR (CSR_BASE + 0x800L)
#define CSR_ETHPHY_CRG_RESET_SIZE 1
static inline uint32_t ethphy_crg_reset_read(void) {
	return csr_read_simple((CSR_BASE + 0x800L));
}
static inline void ethphy_crg_reset_write(uint32_t v) {
	csr_write_simple(v, (CSR_BASE + 0x800L));
}
#define CSR_ETHPHY_RX_INBAND_STATUS_ADDR (CSR_BASE + 0x804L)
#define CSR_ETHPHY_RX_INBAND_STATUS_SIZE 1
static inline uint32_t ethphy_rx_inband_status_read(void) {
	return csr_read_simple((CSR_BASE + 0x804L));
}
#define CSR_ETHPHY_RX_INBAND_STATUS_LINK_STATUS_OFFSET 0
#define CSR_ETHPHY_RX_INBAND_STATUS_LINK_STATUS_SIZE 1
static inline uint32_t ethphy_rx_inband_status_link_status_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 0) & mask );
}
static inline uint32_t ethphy_rx_inband_status_link_status_read(void) {
	uint32_t word = ethphy_rx_inband_status_read();
	return ethphy_rx_inband_status_link_status_extract(word);
}
#define CSR_ETHPHY_RX_INBAND_STATUS_CLOCK_SPEED_OFFSET 1
#define CSR_ETHPHY_RX_INBAND_STATUS_CLOCK_SPEED_SIZE 1
static inline uint32_t ethphy_rx_inband_status_clock_speed_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 1) & mask );
}
static inline uint32_t ethphy_rx_inband_status_clock_speed_read(void) {
	uint32_t word = ethphy_rx_inband_status_read();
	return ethphy_rx_inband_status_clock_speed_extract(word);
}
#define CSR_ETHPHY_RX_INBAND_STATUS_DUPLEX_STATUS_OFFSET 2
#define CSR_ETHPHY_RX_INBAND_STATUS_DUPLEX_STATUS_SIZE 1
static inline uint32_t ethphy_rx_inband_status_duplex_status_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 2) & mask );
}
static inline uint32_t ethphy_rx_inband_status_duplex_status_read(void) {
	uint32_t word = ethphy_rx_inband_status_read();
	return ethphy_rx_inband_status_duplex_status_extract(word);
}
#define CSR_ETHPHY_MDIO_W_ADDR (CSR_BASE + 0x808L)
#define CSR_ETHPHY_MDIO_W_SIZE 1
static inline uint32_t ethphy_mdio_w_read(void) {
	return csr_read_simple((CSR_BASE + 0x808L));
}
static inline void ethphy_mdio_w_write(uint32_t v) {
	csr_write_simple(v, (CSR_BASE + 0x808L));
}
#define CSR_ETHPHY_MDIO_W_MDC_OFFSET 0
#define CSR_ETHPHY_MDIO_W_MDC_SIZE 1
static inline uint32_t ethphy_mdio_w_mdc_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 0) & mask );
}
static inline uint32_t ethphy_mdio_w_mdc_read(void) {
	uint32_t word = ethphy_mdio_w_read();
	return ethphy_mdio_w_mdc_extract(word);
}
static inline uint32_t ethphy_mdio_w_mdc_replace(uint32_t oldword, uint32_t plain_value) {
	uint32_t mask = 0x1;
	return (oldword & (~(mask << 0))) | (mask & plain_value)<< 0 ;
}
static inline void ethphy_mdio_w_mdc_write(uint32_t plain_value) {
	uint32_t oldword = ethphy_mdio_w_read();
	uint32_t newword = ethphy_mdio_w_mdc_replace(oldword, plain_value);
	ethphy_mdio_w_write(newword);
}
#define CSR_ETHPHY_MDIO_W_OE_OFFSET 1
#define CSR_ETHPHY_MDIO_W_OE_SIZE 1
static inline uint32_t ethphy_mdio_w_oe_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 1) & mask );
}
static inline uint32_t ethphy_mdio_w_oe_read(void) {
	uint32_t word = ethphy_mdio_w_read();
	return ethphy_mdio_w_oe_extract(word);
}
static inline uint32_t ethphy_mdio_w_oe_replace(uint32_t oldword, uint32_t plain_value) {
	uint32_t mask = 0x1;
	return (oldword & (~(mask << 1))) | (mask & plain_value)<< 1 ;
}
static inline void ethphy_mdio_w_oe_write(uint32_t plain_value) {
	uint32_t oldword = ethphy_mdio_w_read();
	uint32_t newword = ethphy_mdio_w_oe_replace(oldword, plain_value);
	ethphy_mdio_w_write(newword);
}
#define CSR_ETHPHY_MDIO_W_W_OFFSET 2
#define CSR_ETHPHY_MDIO_W_W_SIZE 1
static inline uint32_t ethphy_mdio_w_w_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 2) & mask );
}
static inline uint32_t ethphy_mdio_w_w_read(void) {
	uint32_t word = ethphy_mdio_w_read();
	return ethphy_mdio_w_w_extract(word);
}
static inline uint32_t ethphy_mdio_w_w_replace(uint32_t oldword, uint32_t plain_value) {
	uint32_t mask = 0x1;
	return (oldword & (~(mask << 2))) | (mask & plain_value)<< 2 ;
}
static inline void ethphy_mdio_w_w_write(uint32_t plain_value) {
	uint32_t oldword = ethphy_mdio_w_read();
	uint32_t newword = ethphy_mdio_w_w_replace(oldword, plain_value);
	ethphy_mdio_w_write(newword);
}
#define CSR_ETHPHY_MDIO_R_ADDR (CSR_BASE + 0x80cL)
#define CSR_ETHPHY_MDIO_R_SIZE 1
static inline uint32_t ethphy_mdio_r_read(void) {
	return csr_read_simple((CSR_BASE + 0x80cL));
}
#define CSR_ETHPHY_MDIO_R_R_OFFSET 0
#define CSR_ETHPHY_MDIO_R_R_SIZE 1
static inline uint32_t ethphy_mdio_r_r_extract(uint32_t oldword) {
	uint32_t mask = 0x1;
	return ( (oldword >> 0) & mask );
}
static inline uint32_t ethphy_mdio_r_r_read(void) {
	uint32_t word = ethphy_mdio_r_read();
	return ethphy_mdio_r_r_extract(word);
}

#endif
