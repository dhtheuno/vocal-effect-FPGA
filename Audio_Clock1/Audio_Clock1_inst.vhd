	component Audio_Clock1 is
		port (
			ref_clk_clk        : in  std_logic := 'X'; -- clk
			ref_reset_reset    : in  std_logic := 'X'; -- reset
			audio_clk_clk      : out std_logic;        -- clk
			reset_source_reset : out std_logic         -- reset
		);
	end component Audio_Clock1;

	u0 : component Audio_Clock1
		port map (
			ref_clk_clk        => CONNECTED_TO_ref_clk_clk,        --      ref_clk.clk
			ref_reset_reset    => CONNECTED_TO_ref_reset_reset,    --    ref_reset.reset
			audio_clk_clk      => CONNECTED_TO_audio_clk_clk,      --    audio_clk.clk
			reset_source_reset => CONNECTED_TO_reset_source_reset  -- reset_source.reset
		);

