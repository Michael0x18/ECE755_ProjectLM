for file in *lm_phy_tx_tb*; do
  mv "$file" "${file//lm_phy_tx_tb/lm_phy_top}"
done
